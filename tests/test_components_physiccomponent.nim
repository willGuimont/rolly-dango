import std/unittest
import cart/ecs/ecs
import cart/components/physiccomponent
import cart/components/positioncomponent
import cart/components/worldtilecomponent

proc makePhysicalAt(reg: var Registry, x: int8, y: int8, z: int8, dx: int8 = 0,
        dy: int8 = 0): Entity =
    result = reg.newEntity()
    reg.addComponent(result, PositionComponent(x: x, y: y, z: z))
    reg.addComponent(result, PhysicsComponent(velocity: Velocity(x: dx, y: dy)))

proc makeFloorAt(reg: var Registry, x: int8, y: int8, z: int8) =
    let floor = reg.newEntity()
    reg.addComponent(floor, PositionComponent(x: x, y: y, z: z))
    reg.addComponent(floor, WorldTileComponent(worldTile: wttTile))

suite "physiccomponent":
    test "entity can fall":
        var reg = newRegistry()
        let entity = reg.makePhysicalAt(0, 0, 2)

        reg.physicsSystem()

        let pos = reg.getComponent[:PositionComponent](entity)
        check pos.z == 1

    test "the fall is stopped by floor":
        var reg = newRegistry()
        let entity = reg.makePhysicalAt(0, 0, 3)
        reg.makeFloorAt(0, 0, 1)

        reg.physicsSystem()
        reg.physicsSystem()
        reg.physicsSystem()

        let pos = reg.getComponent[:PositionComponent](entity)
        check pos.z == 2

    test "velocity make move the entity":
        var reg = newRegistry()
        let entity = reg.makePhysicalAt(0, 0, 1, 1, 0)

        reg.makeFloorAt(0, 0, 0)
        reg.makeFloorAt(1, 0, 0)

        reg.physicsSystem()

        let pos = reg.getComponent[:PositionComponent](entity)
        check pos.x == 1
