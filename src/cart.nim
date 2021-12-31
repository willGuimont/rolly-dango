import cart/wasm4
import cart/assets
import cart/ecs/ecs
import cart/component/spriteComponent
import cart/component/positionComponent

# Call NimMain so that global Nim code in modules will be called,
# preventing unexpected errors
proc NimMain {.importc.}

proc start {.exportWasm.} =
  NimMain()

var decal: tuple[x: int32, y: int32, z: int32] = (x: int32(7), y: int32(4),
    z: int32(6))
var origin: tuple[x: int32, y: int32] = (x: int32(80), y: int32(80))

proc position_to_iso(position: PositionComponent): tuple[x: int32, y: int32] =
  var iso_x: int32 = int32(position.x) * -decal.x + int32(position.y)*decal.x +
      int32(position.z)*0 + origin.x
  var iso_y: int32 = int32(position.x) * decal.y + int32(position.y) * decal.y +
      int32(position.z) * -decal.z + origin.y
  return (x: iso_x, y: isoY)

proc render(reg: Registry) {.exportWasm.} =
  DRAW_COLORS[] = 0x0320

  for entity in entitiesWith(reg, SpriteComponent):
    let (spriteComponent, positionComponent) = reg.getComponents(entity,
        SpriteComponent, PositionComponent)
    let position = position_to_iso(positionComponent)
    blit(addr spriteComponent.sprite.data[0], position.x, position.y,
        spriteComponent.sprite.width,

spriteComponent.sprite.height, spriteComponent.sprite.flags)


proc update {.exportWasm.} =
  var reg = newRegistry()
  var tileEntity1 = reg.newEntity()
  var tileSpriteComponent1 = SpriteComponent(sprite: tile16px)
  var tilePositionComponent1: PositionComponent = PositionComponent(x: 0, y: 0, z: 0)
  reg.addComponent(tileEntity1, tileSpriteComponent1)
  reg.addComponent(tileEntity1, tilePositionComponent1)

  var tileEntity2 = reg.newEntity()
  var tileSpriteComponent2 = SpriteComponent(sprite: tile16px)
  var tilePositionComponent2: PositionComponent = PositionComponent(x: 1, y: 0, z: 0)
  reg.addComponent(tileEntity2, tileSpriteComponent2)
  reg.addComponent(tileEntity2, tilePositionComponent2)

  var tileEntity3 = reg.newEntity()
  var tileSpriteComponent3 = SpriteComponent(sprite: tile16px)
  var tilePositionComponent3: PositionComponent = PositionComponent(x: 0, y: 1, z: 0)
  reg.addComponent(tileEntity3, tileSpriteComponent3)
  reg.addComponent(tileEntity3, tilePositionComponent3)

  var tileEntity4 = reg.newEntity()
  var tileSpriteComponent4 = SpriteComponent(sprite: tile16px)
  var tilePositionComponent4: PositionComponent = PositionComponent(x: 1, y: 1, z: 0)
  reg.addComponent(tileEntity4, tileSpriteComponent4)
  reg.addComponent(tileEntity4, tilePositionComponent4)

  var dangoEntity = reg.newEntity()
  var dangoSpriteComponent = SpriteComponent(sprite: dango16px)
  var dangoPositionComponent: PositionComponent = PositionComponent(x: 0, y: 0, z: 1)
  reg.addComponent(dangoEntity, dangoSpriteComponent)
  reg.addComponent(dangoEntity, dangoPositionComponent)

  render(reg)
