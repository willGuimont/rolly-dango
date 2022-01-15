import std/macros
import ../ecs/ecs
import ../bintree/bintree

type
  WorldTileType* = enum
    wttTile, wttSlopeLeft, wttSlopeRight, wttSlopeFront, wttSlopeBack,
        wttMirrorRight, wttMirrorFront, wttMirrorLeft, wttMirrorBack,
            wttStarting, wttEnding, wttIce, wttPunchFront, wttPunchRight,
                wttPunchLeft, wttPunchBack
  WorldTileComponent* = ref object of Component
    tileType*: WorldTileType
  Level*[T] = object
    x*: int8
    y*: int8
    z*: int8
    data*: ptr T

macro makeLevel*(name: untyped): untyped =
  return quote do:
    const worldSize = int(worldXSize) * int(worldYSize) * int(worldZSize)
    let `name`* = Level[array[worldSize, uint8]](x: worldXSize, y: worldYSize,
        z: worldZSize, data: unsafeAddr worldData)

proc decompressLevel*(data: openArray[uint8], codec: BinaryTree[uint8]): Level[
    array[500, uint8]] =
  echo "a"
