import std/macros
import ../ecs/ecs
import ../components/spritecomponent

type
    AnimationFrame* = ref object
        frame*: Sprite
        shownFrame*: int
    Animation* = object
        frames*: seq[AnimationFrame]
    AnimationComponent* = ref object of Component

macro makeAnimationFrame*(name: untyped, shownFrame: int): untyped =
    let spriteIdent = ident($name & "Sprite")
    let animIdent = ident($name & "AnimFrame")
    return quote do:
        let `animIdent` = AnimationFrame(frame: `spriteIdent`,
                shownFrame: `shownFrame`)
