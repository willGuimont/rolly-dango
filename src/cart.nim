import std/sugar
import std/algorithm
import std/options
import cart/wasm4
import cart/ecs/ecs
import cart/components/spritecomponent
import cart/components/positioncomponent
import cart/components/worldtilecomponent
import cart/components/physiccomponent
import cart/components/inputcomponent
import cart/components/playercomponent
import cart/components/observercomponent
import cart/assets/levels/testlevel08
import cart/assets/levels/testlevel09
import cart/input/gamepad
import cart/state/gamestatemachine

# Call NimMain so that global Nim code in modules will be called,
# preventing unexpected errors
proc NimMain {.importc.}

var theGamepad: Gamepad = getNewGamepad(GAMEPAD1[])
var reg: Registry
var decal: tuple[x: int32, y: int32, z: int32] = (x: int32(7), y: int32(4),
    z: int32(6))
var origin: tuple[x: int32, y: int32] = (x: int32(76), y: int32(40))
var frameCount: int = 0
var sm: StateMachine[LevelState]

var isTitleScreen = true
var isInGame = false
var isEndingScreen = false

proc position_to_iso(position: PositionComponent): tuple[x: int32, y: int32] =
  var iso_x: int32 = int32(position.x) * -decal.x + int32(position.y)*decal.x +
      int32(position.z)*0 + origin.x
  var iso_y: int32 = int32(position.x) * decal.y + int32(position.y) * decal.y +
      int32(position.z) * -decal.z + origin.y
  return (x: iso_x, y: isoY)

proc render(reg: Registry) =

  proc comparePositions(e1, e2: Entity): int =
    let p1 = reg.getComponent[:PositionComponent](e1)
    let p2 = reg.getComponent[:PositionComponent](e2)
    result = cmp(p1.z, p2.z)
    if result == 0:
      result = cmp(p1.x, p2.x)
    if result == 0:
      result = cmp(p1.y, p2.y)
    if result == 0:
      if reg.hasComponent[:WorldTileComponent](e1):
        result = 1
      else:
        result = -1

  DRAW_COLORS[] = 0x4320
  var sprites = reg.entitiesWith(SpriteComponent, PositionComponent)
  for entity in sprites.sorted(comparePositions):
    let (spriteComponent, positionComponent) = reg.getComponents(entity,
        SpriteComponent, PositionComponent)
    let position = position_to_iso(positionComponent)
    blit(addr spriteComponent.sprite.data[][0],
        position.x, position.y,
        spriteComponent.sprite.width,
        spriteComponent.sprite.height, spriteComponent.sprite.flags)

proc buildWorld() =
  reg = newRegistry()
  let level = newLevelList(reg, theGamepad, @[tlevel09, tlevel08])
  sm = newStateMachine(level.get())

proc setPalette() =
  PALETTE[0] = 0xf99dec
  PALETTE[1] = 0xfc49e1
  PALETTE[2] = 0x88fce7
  PALETTE[3] = 0x34bca3

proc start {.exportWasm.} =
  NimMain()
  setPalette()
  buildWorld()

proc runGame() =
  frameCount.inc
  if reg == nil:
    return

  sm.execute()
  sm.transition()

  theGamepad.updateGamepad()
  render(reg)

  processInput(reg)
  reg.playerUpdate()
  if (frameCount mod 15) == 0:
    reg.processObservers()
    reg.physicsSystem()

proc update {.exportWasm.} =
  if isTitleScreen:
    text("Rolly Dango", 0, 0)
    if bool(GAMEPAD1[] and BUTTON_1):
      isTitleScreen = false
      isInGame = true
  elif isInGame:
    runGame()
    if sm.isFinished():
      isInGame = false
      isEndingScreen = true
  elif isEndingScreen:
    text("Finished the game :)", 0, 0)
