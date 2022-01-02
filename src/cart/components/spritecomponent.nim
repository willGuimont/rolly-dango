import std/macros
import ../ecs/ecs

type Sprite* = ref object
    width*: uint32
    height*: uint32
    flags*: uint32
    data*: array[64, uint8]

macro makeSprite*(data: untyped): untyped =
    let width = ident($data & "Width")
    let height = ident($data & "Height")
    let flags = ident($data & "Flags")
    let sprite = ident($data & "Sprite")

    return quote do:
        var `sprite`*: Sprite = Sprite(width: `width`, height: `height`,
                flags: `flags`, data: `data`)

type
    SpriteComponent* = ref object of Component
        sprite*: Sprite
