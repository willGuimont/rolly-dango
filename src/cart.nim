import cart/wasm4
import cart/assets
import cart/ecs/ecs
import cart/component/spritecomponent
import cart/component/positioncomponent

# Call NimMain so that global Nim code in modules will be called,
# preventing unexpected errors
proc NimMain {.importc.}

var reg: Registry
var decal: tuple[x: int32, y: int32, z: int32] = (x: int32(7), y: int32(4),
    z: int32(6))
var origin: tuple[x: int32, y: int32] = (x: int32(76), y: int32(40))
var previousGamepad: uint8
var nbTile: int32 = 8'i32

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

proc buildWorld() =
  reg = newRegistry()

  for i in 0..nbTile:
    for j in 0..nbTile:
      let tileEntity1 = reg.newEntity()
      let tileSpriteComponent1 = SpriteComponent(sprite: tile)
      let tilePositionComponent1: PositionComponent = PositionComponent(
        x: int32(i), y: int32(j), z: 0)
      reg.addComponent(tileEntity1, tileSpriteComponent1)
      reg.addComponent(tileEntity1, tilePositionComponent1)

  var dangoEntity = reg.newEntity()
  var dangoSpriteComponent = SpriteComponent(sprite: dango)
  var dangoPositionComponent: PositionComponent = PositionComponent(x: 0, y: 0, z: 1)
  reg.addComponent(dangoEntity, dangoSpriteComponent)
  reg.addComponent(dangoEntity, dangoPositionComponent)

proc start {.exportWasm.} =
  NimMain()
  buildWorld()

proc update {.exportWasm.} =
  render(reg)

  var gamepad = GAMEPAD1[]
  var pressedThisFrame = gamepad and (gamepad xor previousGamepad)
  previousGamepad = gamepad
  if bool(pressedThisFrame and BUTTON_UP):
    nbTile += 1
    buildWorld()
  elif bool(pressedThisFrame and BUTTON_DOWN):
    nbTile -= 1
    buildWorld()

