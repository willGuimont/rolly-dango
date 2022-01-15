import std/macros
import ../ecs/ecs

type
    Sprite* = ref object
        width*: uint8
        height*: uint8
        flags*: uint8
        data*: ptr array[64, uint8]
    SpriteComponent* = ref object of Component
        sprite*: ptr Sprite

macro makeSprite*(data: untyped): untyped =
    let width = ident($data & "Width")
    let height = ident($data & "Height")
    let flags = ident($data & "Flags")
    let sprite = ident($data & "Sprite")

    return quote do:
        var `sprite`* = Sprite(
                width: `width`, height: `height`,
                flags: `flags`, data: unsafeAddr `data`)
