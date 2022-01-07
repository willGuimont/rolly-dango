import std/unittest
import cart/ecs/ecs
import cart/events/eventqueue
import cart/components/physiccomponent
import cart/components/positioncomponent
import cart/components/worldtilecomponent

proc makePhysicalEntityAt(reg: var Registry, x: int8, y: int8, z: int8,
        dx: int8 = 0, dy: int8 = 0): Entity =
    result = reg.newEntity()
    reg.addComponent(result, PositionComponent(x: x, y: y, z: z))
    reg.addComponent(result, PhysicsComponent(velocity: Velocity(x: dx, y: dy),
            eventQueue: MovementEventQueue()))

proc makeTileAt(reg: var Registry, x: int8, y: int8, z: int8,
        tileType: WorldTileType = wttTile) =
    let floor = reg.newEntity()
    reg.addComponent(floor, PositionComponent(x: x, y: y, z: z))
    reg.addComponent(floor, WorldTileComponent(tileType: tileType))

suite "physiccomponent":
    test "entity can fall":
        var reg = newRegistry()
        let entity = reg.makePhysicalEntityAt(0, 0, 2)

        reg.physicsSystem()

        let pos = reg.getComponent[:PositionComponent](entity)
        check pos.z == 1

    test "the fall is stopped by floor":
        var reg = newRegistry()
        let entity = reg.makePhysicalEntityAt(0, 0, 3)
        reg.makeTileAt(0, 0, 1)

        reg.physicsSystem()
        reg.physicsSystem()
        reg.physicsSystem()

        let pos = reg.getComponent[:PositionComponent](entity)
        check pos.z == 2

    test "velocity make move the entity":
        var reg = newRegistry()
        let entity = reg.makePhysicalEntityAt(0, 0, 1, 1, 0)

        reg.makeTileAt(0, 0, 0)
        reg.makeTileAt(1, 0, 0)

        reg.physicsSystem()

        let pos = reg.getComponent[:PositionComponent](entity)
        check pos.x == 1

    test "moves down slope with velocity":
        var reg = newRegistry()
        let entity = reg.makePhysicalEntityAt(0, 0, 2, 1, 0)

        reg.makeTileAt(0, 0, 1, wttSlopeFront)
        reg.makeTileAt(1, 0, 0)

        reg.physicsSystem()

        let pos = reg.getComponent[:PositionComponent](entity)
        let phy = reg.getComponent[:PhysicsComponent](entity)
        check pos.x == 1
        check pos.z == 1
        check phy.velocity.x == 1

    test "can receive movement messages":
        var reg = newRegistry()
        let entity = reg.makePhysicalEntityAt(0, 0, 2, 1, 0)
        var topic = newTopic[MovementMessage]()
        let phy = reg.getComponent[:PhysicsComponent](entity)
        phy.eventQueue.followTopic(topic)

        topic.sendMessage(mmMoveFront)

        check phy.eventQueue.messages.len() == 1

    test "rolling on flat tile decrease velocity":
        var reg = newRegistry()
        let entity = reg.makePhysicalEntityAt(0, 0, 1, 1, 0)

        reg.makeTileAt(0, 0, 0)
        reg.makeTileAt(1, 0, 0)

        reg.physicsSystem()

        let phy = reg.getComponent[:PhysicsComponent](entity)
        check phy.velocity.x == 0

    test "Move down many slope with increased velocity":
        var reg = newRegistry()
        let entity = reg.makePhysicalEntityAt(0, 0, 3, 0, 0)

        reg.makeTileAt(0, 0, 2, wttSlopeFront)
        reg.makeTileAt(1, 0, 1, wttSlopeFront)
        reg.makeTileAt(2, 0, 0)

        reg.physicsSystem()
        reg.physicsSystem()
        reg.physicsSystem()

        let pos = reg.getComponent[:PositionComponent](entity)
        let phy = reg.getComponent[:PhysicsComponent](entity)
        check pos.x == 2
        check pos.z == 1
        check phy.velocity.x == 2

    test "When moving into slope from opposite direction, go up":
        var reg = newRegistry()
        let entity = reg.makePhysicalEntityAt(0, 0, 1, 1, 0)

        reg.makeTileAt(0, 0, 0)
        reg.makeTileAt(1, 0, 1, wttSlopeBack)

        reg.physicsSystem()

        let pos = reg.getComponent[:PositionComponent](entity)
        let phy = reg.getComponent[:PhysicsComponent](entity)
        check pos.x == 1
        check pos.z == 2
        check phy.velocity.x == 0

    test "When moving into slope from wrong direction, stop":
        var reg = newRegistry()
        let entity = reg.makePhysicalEntityAt(0, 0, 1, 2, 0)

        reg.makeTileAt(0, 0, 0)
        reg.makeTileAt(1, 0, 1, wttSlopeRight)

        reg.physicsSystem()

        let pos = reg.getComponent[:PositionComponent](entity)
        let phy = reg.getComponent[:PhysicsComponent](entity)
        check pos.x == 0
        check pos.z == 1
        check phy.velocity.x == 0

    test "Moves on movement event":
        var reg = newRegistry()
        let entity = reg.makePhysicalEntityAt(0, 0, 1)
        var topic = newTopic[MovementMessage]()
        let phy = reg.getComponent[:PhysicsComponent](entity)
        phy.eventQueue.followTopic(topic)
        topic.sendMessage(mmMoveFront)

        reg.makeTileAt(0, 0, 0)
        reg.makeTileAt(1, 0, 0)

        reg.physicsSystem()

        let pos = reg.getComponent[:PositionComponent](entity)
        check pos.x == 1

    test "When moving into mirror tile from the right direction, can enter tile":
        var reg = newRegistry()
        let entity = reg.makePhysicalEntityAt(0, 0, 1, 1, 0)

        reg.makeTileAt(0, 0, 0)
        reg.makeTileAt(1, 0, 0)
        reg.makeTileAt(1, 0, 1, wttMirrorRight)

        reg.physicsSystem()

        let pos = reg.getComponent[:PositionComponent](entity)
        let phy = reg.getComponent[:PhysicsComponent](entity)
        check pos.x == 1
        check pos.y == 0
        check pos.z == 1
        check phy.velocity.x == 0

    test "When moving into mirror tile from the wrong direction, stops":
        var reg = newRegistry()
        let entity = reg.makePhysicalEntityAt(0, 0, 1, 2, 0)

        reg.makeTileAt(0, 0, 0)
        reg.makeTileAt(1, 0, 0)
        reg.makeTileAt(1, 0, 1, wttMirrorLeft)

        reg.physicsSystem()

        let pos = reg.getComponent[:PositionComponent](entity)
        let phy = reg.getComponent[:PhysicsComponent](entity)
        check pos.x == 0
        check pos.y == 0
        check pos.z == 1
        check phy.velocity.x == 0

    test "When moving into right mirror from front direction, should change to right":
        var reg = newRegistry()
        let entity = reg.makePhysicalEntityAt(0, 0, 1, 3, 0)

        reg.makeTileAt(0, 0, 0)
        reg.makeTileAt(1, 0, 0)
        reg.makeTileAt(1, 1, 0)
        reg.makeTileAt(1, 0, 1, wttMirrorRight)

        reg.physicsSystem()
        reg.physicsSystem()

        let pos = reg.getComponent[:PositionComponent](entity)
        let phy = reg.getComponent[:PhysicsComponent](entity)
        check pos.x == 1
        check pos.y == 1
        check pos.z == 1
        check phy.velocity.x == 0
        check phy.velocity.y == 1
