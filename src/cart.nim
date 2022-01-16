import std/sugar
import std/algorithm
import cart/wasm4
import cart/ecs/ecs
import cart/components/spritecomponent
import cart/components/positioncomponent
import cart/components/worldtilecomponent
import cart/components/physiccomponent
import cart/components/inputcomponent
import cart/components/playercomponent
import cart/systems/observersystem
import cart/assets/levels/rlevel01
import cart/assets/levels/rlevel02
import cart/assets/levels/rlevel03
import cart/assets/levels/rlevel04
import cart/input/gamepad
import cart/state/gamestatemachine
import cart/assets/sprites

# Call NimMain so that global Nim code in modules will be called,
# preventing unexpected errors
proc NimMain {.importc.}

let initialDrawColor = 4611'u16
let spriteDrawColor: uint16 = 0x4320

var theGamepad: Gamepad = getNewGamepad(GAMEPAD1[])
var reg: Registry
const decal: tuple[x: int32, y: int32, z: int32] = (x: int32(7), y: int32(4),
    z: int32(6))
const origin: tuple[x: int32, y: int32] = (x: int32(76), y: int32(40))
var frameCount: uint = 0
var sm: StateMachine[LevelState]

var isTitleScreen = true
var isInGame = false
var isEndingScreen = false

var dangoVelocity*: ref Velocity

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
        let tt = reg.getComponent[:WorldTileComponent](e1).tileType
        if tt == wttMirrorBack or tt == wttMirrorFront or tt ==
            wttMirrorLeft or tt == wttMirrorRight:
          result = 1
      else:
        result = -1

  DRAW_COLORS[] = spriteDrawColor
  var sprites = reg.entitiesWith(SpriteComponent, PositionComponent)
  for entity in sprites.sorted(comparePositions):
    let (spriteComponent, positionComponent) = reg.getComponents(entity,
        SpriteComponent, PositionComponent)
    let position = position_to_iso(positionComponent)
    blit(addr spriteComponent.sprite.data[][0],
        position.x, position.y,
        spriteComponent.sprite.width,
        spriteComponent.sprite.height, spriteComponent.sprite.flags)
  DRAW_COLORS[] = initialDrawColor
  text("Press x to restart", 7, 140)

proc buildWorld() =
  reg = newRegistry()
  let level = newLevelList(addr reg, addr theGamepad, @[unsafeAddr level04,
      unsafeAddr level01, unsafeAddr level02, unsafeAddr level03])
  sm = newStateMachine(level)

proc setPalette() =
  PALETTE[0] = 0xf99dec
  PALETTE[1] = 0xfc49e1
  PALETTE[2] = 0x88fce7
  PALETTE[3] = 0x34bca3

proc start {.exportWasm.} =
  NimMain()
  setPalette()
  buildWorld()

proc displayVelocity() =
  for entity in reg.entitiesWith(PlayerComponent, PhysicsComponent):
    let velocity = reg.getComponent[:PhysicsComponent](entity).velocity
    DRAW_COLORS[] = 0x0003
    text(cstring("Velocity" & $velocity), 0, 0)

proc runGame() =
  frameCount.inc
  if reg == nil:
    return

  sm.execute()
  sm.transition()

  theGamepad.updateGamepad()
  render(reg)

  displayVelocity()

  processInput(reg)
  reg.playerUpdate()
  if (frameCount mod 15) == 0:
    reg.processObservers()
    reg.physicsSystem()

proc update {.exportWasm.} =
  if isTitleScreen:
    DRAW_COLORS[] = initialDrawColor
    text("Rolly Dango", 35, 10)
    text("Help the dango get", 0, 30)
    text("to the exit", 0, 40)
    text("Controls:", 0, 60)
    text("- Arrows to move", 0, 70)
    text("- X to restart level", 0, 80)

    text("Press x to start", 15, 140)

    DRAW_COLORS[] = spriteDrawColor
    blit(addr dangoSprite.data[][0], 20, 6, 16, 16, BLIT_2BPP)
    blit(addr dangoSprite.data[][0], 120, 6, 16, 16, BLIT_2BPP)
    theGamepad.updateGamepad()
    if theGamepad.isButton1():
      isTitleScreen = false
      isInGame = true
  elif isInGame:
    runGame()
    if sm.isFinished():
      isInGame = false
      isEndingScreen = true
  elif isEndingScreen:
    DRAW_COLORS[] = spriteDrawColor
    blit(addr dangoSprite.data[][0], 20, 6, 16, 16, BLIT_2BPP)
    blit(addr dangoSprite.data[][0], 120, 6, 16, 16, BLIT_2BPP)
    DRAW_COLORS[] = initialDrawColor
    text("Rolly Dango", 35, 10)
    text("Finished the game", 10, 30)
