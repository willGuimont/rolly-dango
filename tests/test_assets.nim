import unittest
import cart/assets
import cart/wasm4

suite "assets":
    test "cmdToString Macro returns a sprite":
        const dangoWidth = 16
        const dangoHeight = 16
        const dangoFlags = BLIT_2BPP
        var dango: array[64, uint8] = [0x00'u8, 0x00, 0x00, 0x00, 0x00,
                0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                0x00, 0x00, 0x05, 0x50, 0x00, 0x00, 0x1a, 0xa4, 0x00, 0x00,
                0x6a, 0xa9, 0x00, 0x00, 0x69, 0x99, 0x00, 0x00, 0x69, 0x99,
                0x00, 0x00, 0x6a, 0xa9, 0x00, 0x00, 0x15, 0x54, 0x00, 0x00,
                0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]


        cmdToSprite(dango)
