import ../../components/worldtilecomponent
import ../../bintree/bintree

const worldXSize: int8 = 10
const worldYSize: int8 = 10
const worldZSize: int8 = 5
let codec: BinaryTree = newNode(newNode(newNode(newNode(newNode(newLeaf(15),
    newLeaf(2)), newNode(newLeaf(13), newLeaf(16))), newLeaf(17)), newLeaf(1)),
    newLeaf(0))
const worldData: seq[int8] = @[0b01010101'i8, 0b01010101'i8, 0b01010101'i8,
    0b01010101'i8, 0b01010101'i8, 0b01010101'i8, 0b01010101'i8, 0b01010101'i8,
    0b01010101'i8, 0b01010101'i8, 0b01010101'i8, 0b01010101'i8, 0b01010101'i8,
    0b01010101'i8, 0b01010101'i8, 0b01010101'i8, 0b01010101'i8, 0b01010101'i8,
    0b01010101'i8, 0b01010101'i8, 0b01010101'i8, 0b01010101'i8, 0b01010101'i8,
    0b01010101'i8, 0b01010100'i8, 0b00011111'i8, 0b11111111'i8, 0b11111111'i8,
    0b11111111'i8, 0b11001001'i8, 0b00100100'i8, 0b10011101'i8, 0b10010010'i8,
    0b01001001'i8, 0b00001110'i8, 0b00101001'i8, 0b00100100'i8, 0b10010011'i8,
    0b10111111'i8, 0b11111111'i8, 0b01111111'i8, 0b11111111'i8, 0b11111111'i8,
    0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8,
    0b11111110'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111100'i8,
    0b01111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8,
    0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8,
    0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8,
    0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8,
    0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111111'i8,
    0b11111111'i8, 0b11111111'i8, 0b11111111'i8, 0b11111000'i8]
makeLevel(level03)
