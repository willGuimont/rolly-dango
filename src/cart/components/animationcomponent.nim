import std/macros
import ../ecs/ecs
import ../components/spritecomponent

type
    AnimationFrame* = ref object
        frame*: Sprite
        shownFrame*: int
    Animation* = seq[AnimationFrame]
    AnimationComponent* = ref object of Component

macro makeAnimationFrame(name: untyped): untyped =
    let spriteIdent = ident($name & "AnimFrame")
    let animIdent = ident($name & "AnimFrame")
    return quote do:


