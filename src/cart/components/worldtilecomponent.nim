import std/macros
import std/math
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
  Level* = object
    x*: int8
    y*: int8
    z*: int8
    data*: ptr array[500, int8]

macro makeLevel*(name: untyped): untyped =
  return quote do:
    const worldSize = int(worldXSize) * int(worldYSize) * int(worldZSize)
    let `name`* = Level[array[worldSize, uint8]](x: worldXSize, y: worldYSize,
        z: worldZSize, data: unsafeAddr worldData)

proc decompressLevel*(worldXSize, worldYSize, worldZsize: int8, data: openArray[
    int8], codec: BinaryTree): Level =
  var tiles = create(array[500, int8])
  var currentNode = codec
  var numTiles = 0
  for i in 0..<(data.len() * 8):
    let byteIdx = int(floor(i / 8))
    let bitIdx = int8(i mod 8)
    let s = (data[byteIdx] shl bitIdx) and 0b10000000

    if s == 0:
      currentNode = currentNode.getLeft()
    elif s > 0:
      currentNode = currentNode.getRight()

    if currentNode.isLeaf():
      tiles[numTiles] = currentNode.getData()
      numTiles.inc
      currentNode = codec

  result.x = worldXSize
  result.y = worldYSize
  result.z = worldZsize
  result.data = tiles
