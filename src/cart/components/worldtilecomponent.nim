import std/macros
import ../ecs/ecs

type
  WorldTileType* = enum
    wttTile, wttSlopeLeft, wttSlopeRight, wttSlopeFront, wttSlopeBack,
        wttMirrorRight, wttMirrorFront, wttMirrorLeft, wttMirrorBack,
            wttStarting, wttEnding, wttIce, wttPunchFront, wttPunchRight,
                wttPunchLeft, wttPunchBack
  WorldTileComponent* = ref object of Component
    tileType*: WorldTileType
  Level*[T] = object
    x*: int
    y*: int
    z*: int
    data*: ptr T

macro makeLevel*(name: untyped): untyped =
  return quote do:
    const worldSize = worldXSize * worldYSize * worldZSize
    let `name`* = Level[array[worldSize, uint8]](x: worldXSize, y: worldYSize,
        z: worldZSize, data: unsafeAddr worldData)
