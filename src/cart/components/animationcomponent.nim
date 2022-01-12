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
        lastUpdatedTime: int
        animation: Animation
        frameIndex: int

proc newAnimationComponent*(animation: Animation): AnimationComponent =
    return AnimationComponent(lastUpdatedTime: 0, animation: animation, frameIndex: 0)

macro makeAnimationFrame*(name: untyped, shownFrame: int): untyped =
    let spriteIdent = ident($name & "Sprite")
    let animIdent = ident($name & "AnimFrame")
    return quote do:
        let `animIdent` = AnimationFrame(frame: `spriteIdent`,
                shownFrame: `shownFrame`)

proc animationSystem*(reg: Registry, t: int) =
    for (sprite, anim) in reg.entitiesWithComponents(SpriteComponent,
            AnimationComponent):
        let elapsed = t - anim.lastUpdatedTime
        let currentFrame = anim.animation.frames[anim.frameIndex]
        if elapsed > currentFrame.shownFrame:
            anim.frameIndex = (anim.frameIndex + 1) mod (
                    anim.animation.frames.len())
            let newFrame = anim.animation.frames[anim.frameIndex]
            sprite.sprite = newFrame.frame
