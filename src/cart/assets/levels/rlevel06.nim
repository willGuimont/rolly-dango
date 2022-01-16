import ../../components/worldtilecomponent
import ../../bintree/bintree

const worldXSize: int8 = 10
const worldYSize: int8 = 10
const worldZSize: int8 = 5
let codec: BinaryTree = newNode(newNode(newNode(newNode(newLeaf(3), newNode(
    newNode(newLeaf(16), newNode(newLeaf(8), newLeaf(5))), newNode(newNode(
    newLeaf(2), newLeaf(9)), newNode(newLeaf(15), newLeaf(11))))), newLeaf(14)),
    newLeaf(1)), newLeaf(0))
const worldData: seq[int8] = @[0b01010101'i8, 0b01010101'i8, 0b01010101'i8,
    0b01010101'i8, 0b01010101'i8, 0b01010101'i8, 0b01010101'i8, 0b00101010'i8,
    0b10101010'i8, 0b10101001'i8, 0b01010101'i8, 0b01010101'i8, 0b01001010'i8,
    0b10101010'i8, 0b10101010'i8, 0b01010101'i8, 0b01010101'i8, 0b01010010'i8,
    0b10100101'i8, 0b01010101'i8, 0b01001010'i8, 0b10010101'i8, 0b01010101'i8,
    0b00101010'i8, 0b01001001'i8, 0b00100100'i8, 0b10010010'i8, 0b10101010'i8,
    0b10101010'i8, 0b10110101'i8, 0b01010101'i8, 0b01010110'i8, 0b10101010'i8,
    0b10101010'i8, 0b11010101'i8, 0b01010101'i8, 0b01110101'i8, 0b01010101'i8,
    0b01011110'i8, 0b11111111'i8, 0b11000011'i8, 0b11111111'i8, 0b11111111'i8,
    0b11111111'i8, 0b11100010'i8, 0b10100010'i8, 0b11100011'i8, 0b00110001'i8,
    0b10101010'i8, 0b10101010'i8, 0b10101011'i8, 0b01010101'i8, 0b01010101'i8,
    0b01101010'i8, 0b10101010'i8, 0b00111001'i8, 0b00001010'i8, 0b01010101'i8,
    0b01010111'i8, 0b01001010'i8, 0b10101010'i8, 0b11110000'i8, 0b11111111'i8,
    0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8,
    0b01011111'i8, 0b11011010'i8, 0b11111110'i8, 0b00010101'i8, 0b11111111'i8,
    0b01000111'i8, 0b11111111'i8, 0b10110011'i8, 0b00110000'i8, 0b11111111'i8,
    0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8,
    0b11111111'i8, 0b11111000'i8, 0b10011111'i8, 0b11111111'i8, 0b11111111'i8,
    0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8,
    0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111100'i8]

makeLevel(level06)
