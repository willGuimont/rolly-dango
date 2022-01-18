import ../../components/worldtilecomponent
import ../../bintree/bintree

const worldXSize: int8 = 10
const worldYSize: int8 = 10
const worldZSize: int8 = 5
let codec: BinaryTree = newNode(newNode(newNode(newNode(newLeaf(11), newNode(
    newLeaf(16), newNode(newLeaf(15), newLeaf(3)))), newLeaf(12)), newLeaf(1)),
    newLeaf(0))
const worldData: seq[int8] = @[0b01111111'i8, 0b11101111'i8, 0b11111101'i8,
    0b11111111'i8, 0b10101010'i8, 0b10101010'i8, 0b10101010'i8, 0b10101010'i8,
    0b10101010'i8, 0b10101010'i8, 0b10101010'i8, 0b10101111'i8, 0b11111111'i8,
    0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111011'i8, 0b11111111'i8,
    0b01111111'i8, 0b11101111'i8, 0b11111101'i8, 0b01010101'i8, 0b01010101'i8,
    0b01010101'i8, 0b01010101'i8, 0b01010001'i8, 0b10010101'i8, 0b01010101'i8,
    0b01010111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8,
    0b11111101'i8, 0b11111111'i8, 0b10111111'i8, 0b11110001'i8, 0b11111111'i8,
    0b11111110'i8, 0b00000001'i8, 0b11111111'i8, 0b11111001'i8, 0b00100111'i8,
    0b11001001'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8,
    0b11111111'i8, 0b10001011'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8,
    0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8,
    0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8,
    0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8,
    0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8,
    0b11111111'i8, 0b11111000'i8]

makeLevel(level02)