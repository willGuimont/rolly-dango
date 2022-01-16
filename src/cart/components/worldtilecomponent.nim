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
    codec*: ptr BinaryTree
    data*: ptr seq[int8]

macro makeLevel*(name: untyped): untyped =
  return quote do:
    const worldSize = int(worldXSize) * int(worldYSize) * int(worldZSize)
    let `name`* = Level(x: worldXSize, y: worldYSize,
        z: worldZSize, data: unsafeAddr worldData, codec: unsafeAddr codec)

proc decompressLevel*(l: ptr Level): array[500, int8] =
  var currentNode = l[].codec[]
  var numTiles = 0
  for i in 0..<(l[].data[].len() * 8):
    let byteIdx = int(floor(i / 8))
    let bitIdx = int8(i mod 8)
    let s = (l[].data[][byteIdx] shl bitIdx) and 0b10000000

    if s == 0:
      currentNode = currentNode.getLeft()
    elif s > 0:
      currentNode = currentNode.getRight()

    if currentNode.isLeaf():
      result[numTiles] = currentNode.getData()
      numTiles.inc
      currentNode = l[].codec[]
