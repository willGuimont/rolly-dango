import ../../components/worldtilecomponent
import ../../bintree/bintree

const worldXSize: int8 = 10
const worldYSize: int8 = 10
const worldZSize: int8 = 5
let codec: BinaryTree = newNode(newNode(newNode(newNode(newNode(newLeaf(8),
    newLeaf(16)), newNode(newNode(newLeaf(15), newLeaf(2)), newNode(newLeaf(7),
    newLeaf(3)))), newLeaf(14)), newLeaf(1)), newLeaf(0))
const worldData: array[83, int8] = [0b01010010'i8, 0b01001001'i8, 0b00100100'i8,
    0b10010010'i8, 0b10101010'i8, 0b10101010'i8, 0b01001010'i8, 0b10101010'i8,
    0b10101001'i8, 0b00101010'i8, 0b10101010'i8, 0b10100100'i8, 0b10101010'i8,
    0b10101010'i8, 0b10010010'i8, 0b10101010'i8, 0b10101010'i8, 0b01001010'i8,
    0b10101010'i8, 0b10101001'i8, 0b00101010'i8, 0b10101010'i8, 0b10100100'i8,
    0b10101010'i8, 0b10101010'i8, 0b10010010'i8, 0b01001001'i8, 0b00100100'i8,
    0b10010010'i8, 0b01000100'i8, 0b00010111'i8, 0b11111000'i8, 0b11000011'i8,
    0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8,
    0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8,
    0b00000111'i8, 0b11111000'i8, 0b01111111'i8, 0b11111111'i8, 0b11111111'i8,
    0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8,
    0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8,
    0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8,
    0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8,
    0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8,
    0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8,
    0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111100'i8]

let tlevel02* = decompressLevel(worldXSize, worldYSize, worldZsize, worldData, codec)
