import std/unittest
import cart/ecs/ecs
import cart/components/physiccomponent
import cart/components/positioncomponent
import cart/components/worldtilecomponent

proc makePhysicalEntityAt(reg: var Registry, x: int8, y: int8, z: int8,
        dx: int8 = 0, dy: int8 = 0): Entity =
    result = reg.newEntity()
    reg.addComponent(result, PositionComponent(x: x, y: y, z: z))
    reg.addComponent(result, PhysicsComponent(velocity: Velocity(x: dx, y: dy)))

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
        check true
        # TODO
