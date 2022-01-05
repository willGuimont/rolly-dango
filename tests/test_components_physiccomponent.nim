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

    test "When entity has velocity on flat tile, moves forward and looses velocity":
        var reg = newRegistry()
        let entity = reg.newEntity()
        reg.addComponent(entity, PositionComponent(x: 0, y: 0, z: 1))
        reg.addComponent(entity, PhysicsComponent())
        let tile1 = reg.newEntity()
        reg.addComponent(tile1, PositionComponent(x: 0, y: 0, z: 0))
        reg.addComponent(tile1, WorldTileComponent(worldTile: wttTile))
        let tile2 = reg.newEntity()
        reg.addComponent(tile2, PositionComponent(x: 0, y: 1, z: 0))
        reg.addComponent(tile2, WorldTileComponent(worldTile: wttTile))
        let phy = reg.getComponent[:PhysicsComponent](entity)

        phy.velocity = 1
        phy.direction = dRight

        reg.physicsSystem()
        #This call should have no impact, if it does it's a problem
        reg.physicsSystem()

        let pos = reg.getComponent[:PositionComponent](entity)

        check pos.y == 1
        check pos.z == 1
        check phy.velocity == 0
        check phy.direction == dNone

    test "When on right slope, should gain velocity in slope direction":
        var reg = newRegistry()
        let entity = reg.newEntity()
        reg.addComponent(entity, PositionComponent(x: 0, y: 0, z: 2))
        reg.addComponent(entity, PhysicsComponent())
        let slopeRight = reg.newEntity()
        reg.addComponent(slopeRight, PositionComponent(x: 0, y: 0, z: 1))
        reg.addComponent(slopeRight, WorldTileComponent(
                worldTile: wttSlopeRight))

        reg.physicsSystem()

        let pos = reg.getComponent[:PositionComponent](entity)
        let phy = reg.getComponent[:PhysicsComponent](entity)
        check pos.y == 0
        check pos.z == 2
        check phy.velocity == 1
        check phy.direction == Direction.dRight

    test "When on right slope, move to right and down, increase velocity":
        var reg = newRegistry()
        let entity = reg.newEntity()
        reg.addComponent(entity, PositionComponent(x: 0, y: 0, z: 2))
        reg.addComponent(entity, PhysicsComponent())
        let slopeRight = reg.newEntity()
        reg.addComponent(slopeRight, PositionComponent(x: 0, y: 0, z: 1))
        reg.addComponent(slopeRight, WorldTileComponent(
                worldTile: wttSlopeRight))
        let tile1 = reg.newEntity()
        reg.addComponent(tile1, PositionComponent(x: 0, y: 1, z: 0))
        reg.addComponent(tile1, WorldTileComponent(worldTile: wttTile))

        reg.physicsSystem()
        reg.physicsSystem()

        let pos = reg.getComponent[:PositionComponent](entity)
        let phy = reg.getComponent[:PhysicsComponent](entity)
        check pos.y == 1
        check pos.z == 1
        check phy.velocity == 1
        check phy.direction == Direction.dRight

    test "When sliding from slope to tile, preserve momentum":
        var reg = newRegistry()
        let entity = reg.newEntity()
        reg.addComponent(entity, PositionComponent(x: 0, y: 0, z: 2))
        reg.addComponent(entity, PhysicsComponent())
        let slopeRight = reg.newEntity()
        reg.addComponent(slopeRight, PositionComponent(x: 0, y: 0, z: 1))
        reg.addComponent(slopeRight, WorldTileComponent(
                worldTile: wttSlopeRight))
        let tile1 = reg.newEntity()
        reg.addComponent(tile1, PositionComponent(x: 0, y: 1, z: 0))
        reg.addComponent(tile1, WorldTileComponent(worldTile: wttTile))
        let tile2 = reg.newEntity()
        reg.addComponent(tile2, PositionComponent(x: 0, y: 2, z: 0))
        reg.addComponent(tile2, WorldTileComponent(worldTile: wttTile))

        reg.physicsSystem()
        reg.physicsSystem()
        reg.physicsSystem()
        #This call should have no impact, if it does it's a problem
        reg.physicsSystem()

        let pos = reg.getComponent[:PositionComponent](entity)
        let phy = reg.getComponent[:PhysicsComponent](entity)
        check pos.y == 2
        check pos.z == 1
        check phy.velocity == 0
        check phy.direction == Direction.dNone
