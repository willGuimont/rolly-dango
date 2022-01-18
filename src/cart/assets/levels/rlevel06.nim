import ../../components/worldtilecomponent
import ../../bintree/bintree

const worldXSize: int8 = 10
const worldYSize: int8 = 10
const worldZSize: int8 = 5
let codec: BinaryTree = newNode(newNode(newLeaf(1), newNode(newNode(newNode(
    newLeaf(3), newNode(newNode(newLeaf(9), newNode(newLeaf(8), newLeaf(5))),
    newNode(newNode(newLeaf(2), newLeaf(15)), newNode(newLeaf(16), newLeaf(
    11))))), newLeaf(14)), newLeaf(17))), newLeaf(0))
const worldData: seq[int8] = @[0b00000000'i8, 0b00000000'i8, 0b00000000'i8,
    0b00000000'i8, 0b00000000'i8, 0b00000000'i8, 0b00000000'i8, 0b00000000'i8,
    0b00000000'i8, 0b00000000'i8, 0b00000000'i8, 0b00000000'i8, 0b00000101'i8,
    0b00000000'i8, 0b00000001'i8, 0b01000101'i8, 0b00000000'i8, 0b00000001'i8,
    0b01000101'i8, 0b00000000'i8, 0b00000001'i8, 0b01000101'i8, 0b00000000'i8,
    0b00000001'i8, 0b01000101'i8, 0b01010101'i8, 0b01010101'i8, 0b01010101'i8,
    0b01010101'i8, 0b00011011'i8, 0b01101101'i8, 0b10111111'i8, 0b01101101'i8,
    0b10110110'i8, 0b11111101'i8, 0b10110110'i8, 0b11011011'i8, 0b11110110'i8,
    0b11011011'i8, 0b01101111'i8, 0b11001111'i8, 0b11101110'i8, 0b01111111'i8,
    0b11010001'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11110100'i8,
    0b10101010'i8, 0b01011101'i8, 0b01010011'i8, 0b00111011'i8, 0b01101101'i8,
    0b10110110'i8, 0b11111101'i8, 0b10110110'i8, 0b11011011'i8, 0b11110110'i8,
    0b11011011'i8, 0b01101111'i8, 0b11011011'i8, 0b01101101'i8, 0b10111111'i8,
    0b00111111'i8, 0b10111010'i8, 0b00111111'i8, 0b11111111'i8, 0b11111111'i8,
    0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11011011'i8, 0b01101101'i8,
    0b10110100'i8, 0b11011111'i8, 0b01101101'i8, 0b10110110'i8, 0b11111101'i8,
    0b10110110'i8, 0b11011011'i8, 0b11110110'i8, 0b11011011'i8, 0b01101111'i8,
    0b11010001'i8, 0b11111101'i8, 0b00111011'i8, 0b11111111'i8, 0b11111111'i8,
    0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b10100111'i8,
    0b11111111'i8, 0b11101000'i8, 0b01011010'i8, 0b11111111'i8, 0b01001000'i8,
    0b10001111'i8, 0b11111101'i8, 0b01111111'i8, 0b11111111'i8, 0b11111111'i8,
    0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11100000'i8]


makeLevel(level06)