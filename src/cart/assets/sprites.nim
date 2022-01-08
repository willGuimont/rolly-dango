import ../components/spritecomponent
import ../wasm4

const dangoWidth = 16
const dangoHeight = 16
const dangoFlags = BLIT_2BPP
const dango: array[64, uint8] = [0x00'u8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x05, 0x50,
        0x00, 0x00, 0x1a, 0xa4, 0x00, 0x00, 0x6a, 0xa9, 0x00, 0x00, 0x69, 0x99,
        0x00, 0x00, 0x69, 0x99, 0x00, 0x00, 0x6a, 0xa9, 0x00, 0x00, 0x15, 0x54,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]

const tileWidth = 16
const tileHeight = 16
const tileFlags = BLIT_2BPP
const tile: array[64, uint8] = [0x00'u8, 0x01, 0x00, 0x00, 0x00, 0x1f, 0xd0, 0x00,
    0x01, 0xff, 0xfd, 0x00, 0x1f, 0xff, 0xff, 0xd0, 0xbf, 0xff, 0xff, 0xf8,
    0x67, 0xff, 0xff, 0x64, 0xaa, 0x7f, 0xf6, 0xa8, 0x6a, 0xa7, 0x6a, 0xa4,
    0xaa, 0xaa, 0xaa, 0xa8, 0x6a, 0xa9, 0xaa, 0xa4, 0xaa, 0xaa, 0xaa, 0xa8,
    0x1a, 0xa9, 0xaa, 0x90, 0x01, 0xaa, 0xa9, 0x00, 0x00, 0x19, 0x90, 0x00,
    0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]

const slopeRightWidth = 16
const slopeRightHeight = 16
const slopeRightFlags = BLIT_2BPP
const slopeRight: array[64, uint8] = [0x00'u8, 0x01, 0x40, 0x00, 0x00, 0x16, 0x90,
        0x00, 0x01, 0x6a, 0xa4, 0x00, 0x16, 0xaa, 0xa4, 0x00, 0x5a, 0xaa, 0xa9,
        0x00, 0x66, 0xaa, 0xaa, 0x40, 0x69, 0xaa, 0xaa, 0x90, 0x69, 0xaa, 0xaa,
        0x90, 0x6a, 0x6a, 0xaa, 0xa4, 0x6a, 0x9a, 0xaa, 0xa4, 0x6a, 0xa6, 0xaa,
        0xa4, 0x16, 0xa6, 0xaa, 0x50, 0x01, 0x69, 0xa5, 0x00, 0x00, 0x15, 0x50,
        0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]


const slopeFrontWidth = 16
const slopeFrontHeight = 16
const slopeFrontFlags = BLIT_2BPP
const slopeFront: array[64, uint8] = [0x00'u8, 0x05, 0x00, 0x00, 0x00, 0x1a, 0x50,
        0x00, 0x00, 0x6a, 0xa5, 0x00, 0x00, 0x6a, 0xaa, 0x50, 0x01, 0xaa, 0xaa,
        0x94, 0x06, 0xaa, 0xaa, 0x64, 0x1a, 0xaa, 0xa9, 0xa4, 0x1a, 0xaa, 0xa9,
        0xa4, 0x6a, 0xaa, 0xa6, 0xa4, 0x6a, 0xaa, 0x9a, 0xa4, 0x6a, 0xaa, 0x6a,
        0xa4, 0x16, 0xaa, 0x6a, 0x50, 0x01, 0x69, 0xa5, 0x00, 0x00, 0x15, 0x50,
        0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]

const slopeLeftWidth = 16
const slopeLeftHeight = 16
const slopeLeftFlags = BLIT_2BPP
const slopeLeft: array[64, uint8] = [0x00'u8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x01,
        0x64, 0x00, 0x00, 0x16, 0xa4, 0x00, 0x01, 0x6a, 0xa4, 0x00, 0x15, 0xaa,
        0xa4, 0x01, 0x69, 0xaa, 0xa4, 0x16, 0xa9, 0xaa, 0xa4, 0x6a, 0xa9, 0xaa,
        0xa4, 0x16, 0xa9, 0xaa, 0x50, 0x01, 0x69, 0xa5, 0x00, 0x00, 0x15, 0x50,
        0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]

const slopeBackWidth = 16
const slopeBackHeight = 16
const slopeBackFlags = BLIT_2BPP
const slopeBack: array[64, uint8] = [0x00'u8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x65, 0x00, 0x00,
        0x00, 0x6a, 0x50, 0x00, 0x00, 0x6a, 0xa5, 0x00, 0x00, 0x6a, 0xa9, 0x50,
        0x00, 0x6a, 0xa9, 0xa5, 0x00, 0x6a, 0xa9, 0xaa, 0x50, 0x6a, 0xa9, 0xaa,
        0xa4, 0x16, 0xa9, 0xaa, 0x50, 0x01, 0x69, 0xa5, 0x00, 0x00, 0x15, 0x50,
        0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]

const mirrorRightWidth = 16
const mirrorRightHeight = 16
const mirrorRightFlags = BLIT_2BPP
const mirrorRight: array[64, uint8] = [0x00'u8, 0x00, 0x40, 0x00, 0x00, 0x07,
    0xc0, 0x00, 0x00, 0x7f, 0x40, 0x00, 0x07, 0xff, 0xc0, 0x00, 0x7f, 0xff,
    0x40, 0x00, 0xa7, 0xff, 0xc0, 0x00, 0x6a, 0x7f, 0x40, 0x00, 0xaa, 0xa7,
    0xc0, 0x00, 0x6a, 0xaa, 0x40, 0x00, 0xaa, 0xaa, 0x80, 0x00, 0x6a, 0xaa,
    0x40, 0x00, 0x06, 0xaa, 0x80, 0x00, 0x00, 0x6a, 0x40, 0x00, 0x00, 0x06,
    0x80, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00]

const mirrorLeftWidth = 16
const mirrorLeftHeight = 16
const mirrorLeftFlags = BLIT_2BPP
const mirrorLeft: array[64, uint8] = [0x00'u8, 0x01, 0x00, 0x00, 0x00, 0x03, 0xd0,
    0x00, 0x00, 0x01, 0xfd, 0x00, 0x00, 0x03, 0xff, 0xd0, 0x00, 0x01, 0xff,
    0xfd, 0x00, 0x03, 0xff, 0xda, 0x00, 0x01, 0xfd, 0xa9, 0x00, 0x03, 0xda,
    0xaa, 0x00, 0x01, 0xaa, 0xa9, 0x00, 0x02, 0xaa, 0xaa, 0x00, 0x01, 0xaa,
    0xa9, 0x00, 0x02, 0xaa, 0x90, 0x00, 0x01, 0xa9, 0x00, 0x00, 0x02, 0x90,
    0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]

const mirrorFrontWidth = 16
const mirrorFrontHeight = 16
const mirrorFrontFlags = BLIT_2BPP
const mirrorFront: array[64, uint8] = [0x00'u8, 0x01, 0x00, 0x00, 0x00, 0x1f,
    0xd0, 0x00, 0x01, 0xff, 0xfd, 0x00, 0x1f, 0xff, 0xff, 0xd0, 0xf7, 0x77,
    0x77, 0x7c, 0x6a, 0xaa, 0xaa, 0xa4, 0xae, 0xae, 0xae, 0xa8, 0x6a, 0xba,
    0xba, 0xa4, 0xaa, 0xea, 0xea, 0xe8, 0x6a, 0xaa, 0xaa, 0xa4, 0x19, 0x99,
    0x99, 0x90, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]

const mirrorBackWidth = 16
const mirrorBackHeight = 16
const mirrorBackFlags = BLIT_2BPP
const mirrorBack: array[64, uint8] = [0x00'u8, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x1d, 0xdd, 0xdd, 0xd0, 0xbf, 0xff,
    0xff, 0xf8, 0x67, 0xff, 0xff, 0x64, 0xaa, 0x7f, 0xf6, 0xa8, 0x6a, 0xa7,
    0x6a, 0xa4, 0xaa, 0xaa, 0xaa, 0xa8, 0x6a, 0xa9, 0xaa, 0xa4, 0xaa, 0xaa,
    0xaa, 0xa8, 0x1a, 0xa9, 0xaa, 0x90, 0x01, 0xaa, 0xa9, 0x00, 0x00, 0x19,
    0x90, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]

const cupWidth = 16
const cupHeight = 16
const cupFlags = BLIT_2BPP
const cup: array[64, uint8] = [0x00'u8,0x00,0x00,0x00,0x00,0x05,0x40,0x00,0x00,0x15,0x50,0x00,0x00,0x05,0x40,0x00,0x00,0x01,0x00,0x00,0x00,0x05,0x40,0x00,0x00,0x15,0x50,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00]


makeSprite(dango)
makeSprite(tile)
makeSprite(slopeRight)
makeSprite(slopeFront)
makeSprite(slopeLeft)
makeSprite(slopeBack)
makeSprite(mirrorRight)
makeSprite(mirrorFront)
makeSprite(mirrorLeft)
makeSprite(mirrorBack)
makeSprite(cup)
