import ../../components/worldtilecomponent
import ../../bintree/bintree

const worldXSize: int8 = 10
const worldYSize: int8 = 10
const worldZSize: int8 = 5
let codec: BinaryTree = newNode(newNode(newNode(newLeaf(3), newNode(newNode(
    newLeaf(16), newNode(newLeaf(15), newLeaf(12))), newLeaf(17))), newLeaf(1)),
    newLeaf(0))
const worldData: seq[int8] = @[0b01010101'i8, 0b01010101'i8, 0b01010101'i8,
    0b01010101'i8, 0b01010101'i8, 0b01010101'i8, 0b01010101'i8, 0b01010101'i8,
    0b01010101'i8, 0b01010101'i8, 0b01010101'i8, 0b01010101'i8, 0b01010101'i8,
    0b01010101'i8, 0b01010101'i8, 0b01010101'i8, 0b01010101'i8, 0b01010101'i8,
    0b01010101'i8, 0b01010101'i8, 0b01010101'i8, 0b01010101'i8, 0b01010101'i8,
    0b01010101'i8, 0b01010100'i8, 0b10101111'i8, 0b00111111'i8, 0b11111111'i8,
    0b11111111'i8, 0b11011111'i8, 0b01111111'i8, 0b11111111'i8, 0b00011111'i8,
    0b11000111'i8, 0b11111111'i8, 0b11111101'i8, 0b11111111'i8, 0b11110010'i8,
    0b11111111'i8, 0b11111111'i8, 0b11100111'i8, 0b11111111'i8, 0b11111111'i8,
    0b11111111'i8, 0b11000111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8,
    0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8,
    0b11110011'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8,
    0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8,
    0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11100100'i8, 0b11111111'i8,
    0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8,
    0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111110'i8]
makeLevel(level08)
