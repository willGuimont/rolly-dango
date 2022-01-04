import std/unittest
import cart/ecs/ecs
import cart/components/physiccomponent
import cart/components/positioncomponent
import cart/components/worldtilecomponent


suite "physiccomponent":
    test "entity can fall":
        var reg = newRegistry()
        let entity = reg.newEntity()
        reg.addComponent(entity, PositionComponent(x: 0, y: 0, z: 2))
        reg.addComponent(entity, PhysicsComponent())

        reg.physicsSystem()

        let pos = reg.getComponent[:PositionComponent](entity)
        check pos.z == 1

    test "the fall is stopped by floor":
        var reg = newRegistry()
        let entity = reg.newEntity()
        reg.addComponent(entity, PositionComponent(x: 0, y: 0, z: 3))
        reg.addComponent(entity, PhysicsComponent())
        let floor = reg.newEntity()
        reg.addComponent(floor, PositionComponent(x: 0, y: 0, z: 1))
        reg.addComponent(floor, WorldTileComponent(worldTile: wttTile))

        reg.physicsSystem()
        reg.physicsSystem()
        reg.physicsSystem()

        let pos = reg.getComponent[:PositionComponent](entity)
        check pos.z == 2

