import std/macros
import std/options
import ../ecs/ecs
import ../assets/sprites
import ../components/spritecomponent
import ../components/positioncomponent

type
  WorldTileType* = enum
    wttTile, wttSlopeLeft, wttSlopeRight, wttSlopeFront, wttSlopeBack,
        wttMirrorRight, wttMirrorFront, wttMirrorLeft, wttMirrorBack
  WorldTileComponent* = ref object of Component
    tileType*: WorldTileType
  Level*[T] = object
    x: int
    y: int
    z: int
    data: T

macro makeLevel*(name: untyped): untyped =
  return quote do:
    const worldSize = worldXSize * worldYSize * worldZSize
    var `name`* = Level[array[worldSize, uint8]](x: worldXSize, y: worldYSize,
        z: worldZSize, data: worldData)

proc intToTileType(x: uint8): Option[WorldTileType] =
  case x:
    of 0: none(WorldTileType)
    of 1: some(wttTile)
    of 2: some(wttSlopeFront)
    of 3: some(wttSlopeRight)
    of 4: some(wttSlopeLeft)
    of 5: some(wttSlopeBack)
    of 6: some(wttMirrorFront)
    of 7: some(wttMirrorRight)
    of 8: some(wttMirrorLeft)
    of 9: some(wttMirrorBack)
    else: none(WorldTileType)

proc intToSprite(x: uint8): Option[Sprite] =
  case x:
    of 0: none(Sprite)
    of 1: some(tileSprite)
    of 2: some(slopeFrontSprite)
    of 3: some(slopeRightSprite)
    of 4: some(slopeLeftSprite)
    of 5: some(slopeBackSprite)
    of 6: some(mirrorFrontSprite)
    of 7: some(mirrorRightSprite)
    of 8: some(mirrorLeftSprite)
    of 9: some(mirrorBackSprite)
    else: none(Sprite)

proc buildLevel*[T](reg: Registry, level: Level[T]) =
  let x = level.x
  let y = level.y
  let z = level.z
  for i in 0..<x:
    for j in 0..<y:
      for k in 0..<z:
        let idx = i + j * x + k * x * y
        let tileType = level.data[idx]
        let ott = intToTileType(tileType)
        let oSprite = intToSprite(tileType)
        if ott.isSome() and oSprite.isSome():
          let tt = ott.get()
          var e = reg.newEntity()
          reg.addComponent(e, SpriteComponent(sprite: oSprite.get()))
          reg.addComponent(e, PositionComponent(x: int8(i), y: int8(j), z: int8(k)))
          reg.addComponent(e, WorldTileComponent(tileType: tt))
