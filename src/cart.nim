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

proc render(reg: Registry) {.exportWasm.} =
  for entity in entitiesWith(reg, SpriteComponent):
    var component = getComponent[SpriteComponent](reg, entity)
    blit(addr component.sprite.data[0], 76, 76, component.sprite.width,
        component.sprite.height, component.sprite.flags)


proc update {.exportWasm.} =
  var reg = newRegistry()
  var tileEntity = reg.newEntity()
  var tileSpriteComponent = SpriteComponent(sprite: tile16px)
  var tilePositionComponent: PositionComponent = PositionComponent(x: 0, y: 0, z: 0)
  reg.addComponent(tileEntity, tileSpriteComponent)
  #reg.addComponent(tileEntity, tilePositionComponent)

  var dangoEntity = reg.newEntity()
  var dangoSpriteComponent = SpriteComponent(sprite: dango16px)
  var dangoPositionComponent: PositionComponent = PositionComponent(x: 0, y: 0, z: 1)
  reg.addComponent(dangoEntity, dangoSpriteComponent)
  #reg.addComponent(dangoEntity, dangoPositionComponent)

  render(reg)

  DRAW_COLORS[] = 2
  text("Hello from Nim!", 10, 10)

  var gamepad = GAMEPAD1[]
  if bool(gamepad and BUTTON_1):
    DRAW_COLORS[] = 4

  blit(addr dango16px.data[0], 76, 76, 8, 8, BLIT_1BPP)
  text("Press X to blink", 16, 90)
