import std/macros
import ../ecs/ecs
import ../components/spritecomponent
import ../components/physiccomponent

type
    AnimationFrame* = ref object
        frame*: ptr Sprite
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
        let `animIdent` = AnimationFrame(frame: unsafeAddr `spriteIdent`,
                shownFrame: `shownFrame`)

proc animationSystem*(reg: Registry, t: int) =
    for (sprite, anim, phy) in reg.entitiesWithComponents(SpriteComponent,
            AnimationComponent, PhysicsComponent):
        let elapsed = t - anim.lastUpdatedTime
        if abs(phy.velocity.x) + abs(phy.velocity.y) > 0:
            anim.frameIndex = 3
        let currentFrame = anim.animation.frames[anim.frameIndex]
        if elapsed > currentFrame.shownFrame:
            anim.frameIndex = (anim.frameIndex + 1) mod (
                    anim.animation.frames.len())
            let newFrame = anim.animation.frames[anim.frameIndex]
            sprite.sprite = newFrame.frame
