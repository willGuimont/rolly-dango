import ../../components/worldtilecomponent
import ../../bintree/bintree

const worldXSize: int8 = 10
const worldYSize: int8 = 10
const worldZSize: int8 = 5
let codec: BinaryTree = newNode(newNode(newNode(newNode(newNode(newNode(newLeaf(
    17), newLeaf(15)), newNode(newLeaf(7), newLeaf(8))), newNode(newNode(
    newLeaf(12), newLeaf(16)), newLeaf(3))), newLeaf(14)), newLeaf(1)), newLeaf(0))
const worldData: seq[int8] = @[0b01010101'i8, 0b01010101'i8, 0b01010101'i8,
    0b01010101'i8, 0b01010101'i8, 0b01010101'i8, 0b00101010'i8, 0b10100101'i8,
    0b01010100'i8, 0b10101010'i8, 0b10010101'i8, 0b01010010'i8, 0b10101010'i8,
    0b01010101'i8, 0b01001010'i8, 0b10101001'i8, 0b01010101'i8, 0b00100100'i8,
    0b10010101'i8, 0b01010101'i8, 0b01010100'i8, 0b10101010'i8, 0b10101010'i8,
    0b10100101'i8, 0b01010101'i8, 0b01010101'i8, 0b01010111'i8, 0b11000000'i8,
    0b11110000'i8, 0b01111111'i8, 0b11100011'i8, 0b11110011'i8, 0b11111111'i8,
    0b00111111'i8, 0b11110001'i8, 0b11111111'i8, 0b11111111'i8, 0b11111110'i8,
    0b00010111'i8, 0b00001111'i8, 0b11111111'i8, 0b11110011'i8, 0b11111111'i8,
    0b10001001'i8, 0b11111000'i8, 0b10111111'i8, 0b11111111'i8, 0b11111111'i8,
    0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8,
    0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8,
    0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8,
    0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8,
    0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8,
    0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8,
    0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11000000'i8]

makeLevel(level04)
