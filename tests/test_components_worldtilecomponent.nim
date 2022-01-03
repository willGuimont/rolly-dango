import unittest
import std/sequtils
import cart/components/worldtilecomponent
import cart/ecs/ecs

const worldXSize: int = 10
const worldYSize: int = 10
const worldZSize: int = 5
const worldSize: int = 500
const worldData: array[worldSize, uint8] = [1'u8, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 4,
    0, 0, 0, 0, 0, 0, 0, 5, 1, 1, 2, 0, 0, 0, 0, 0, 0, 5, 1, 1, 2, 0, 0, 0, 0,
    0, 0, 0, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

makeLevel(aLevel, worldSize)

proc notAir(x: uint8): int =
    return if x != 0: 1 else: 0

proc isTile(x: uint8): int =
    return if x == 1: 1 else: 0

proc isSlopeFront(x: uint8): int =
    return if x == 2: 1 else: 0

proc isSlopeRight(x: uint8): int =
    return if x == 3: 1 else: 0

proc isSlopeLeft(x: uint8): int =
    return if x == 4: 1 else: 0

proc isSlopeBack(x: uint8): int =
    return if x == 5: 1 else: 0

proc countOf(reg: Registry, t: WorldTileType): int =
    result = 0
    for e in reg.entitiesWith(WorldTileComponent):
        let c = reg.getComponent[:WorldTileComponent](e)
        if c.worldTile == t:
            result.inc

suite "worldtilecomponent":
    test "build level creates enough entities of each type":
        var reg = newRegistry()
        reg.buildLevel(aLevel)

        check len(reg) == worldData.map(notAir).foldl(a + b)
        check reg.countOf(wttTile) == worldData.map(isTile).foldl(a + b)
        check reg.countOf(wttSlopeFront) == worldData.map(isSlopeFront).foldl(
                a + b)
        check reg.countOf(wttSlopeRight) == worldData.map(isSlopeRight).foldl(
                a + b)
        check reg.countOf(wttSlopeLeft) == worldData.map(isSlopeLeft).foldl(a + b)
        check reg.countOf(wttSlopeBack) == worldData.map(isSlopeBack).foldl(a + b)
