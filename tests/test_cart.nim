import unittest
import cart/ecs/ecs
import cart/component/spritecomponent
import cart/component/positioncomponent
import cart/assets

suite "cart":

    test "doesn't fuck up when registry global":
        var reg: Registry = newRegistry()
        proc update() =
            for i in 0..8:
                for j in 0..8:
                    var tileEntity1 = reg.newEntity()
                    var tileSpriteComponent1 = SpriteComponent(sprite: tile16px)
                    var tilePositionComponent1: PositionComponent = PositionComponent(
                        x: int32(i), y: int32(j), z: 0)
                    reg.addComponent(tileEntity1, tileSpriteComponent1)
                    reg.addComponent(tileEntity1, tilePositionComponent1)

            var dangoEntity = reg.newEntity()
            var dangoSpriteComponent = SpriteComponent(sprite: dango16px)
            var dangoPositionComponent: PositionComponent = PositionComponent(
                    x: 0, y: 0, z: 1)
            reg.addComponent(dangoEntity, dangoSpriteComponent)
            reg.addComponent(dangoEntity, dangoPositionComponent)

    test "doesn't fuck up when render":
        var reg: Registry = newRegistry()
        proc start() =
            for i in 0..8:
                for j in 0..8:
                    var tileEntity1 = reg.newEntity()
                    var tileSpriteComponent1 = SpriteComponent(sprite: tile16px)
                    var tilePositionComponent1: PositionComponent = PositionComponent(
                        x: int32(i), y: int32(j), z: 0)
                    reg.addComponent(tileEntity1, tileSpriteComponent1)
                    reg.addComponent(tileEntity1, tilePositionComponent1)

            var dangoEntity = reg.newEntity()
            var dangoSpriteComponent = SpriteComponent(sprite: dango16px)
            var dangoPositionComponent: PositionComponent = PositionComponent(
                    x: 0, y: 0, z: 1)
            reg.addComponent(dangoEntity, dangoSpriteComponent)
            reg.addComponent(dangoEntity, dangoPositionComponent)

        proc render() =
            for entity in entitiesWith(reg, SpriteComponent):
                let (spriteComponent, positionComponent) = reg.getComponents(entity,
                    SpriteComponent, PositionComponent)
