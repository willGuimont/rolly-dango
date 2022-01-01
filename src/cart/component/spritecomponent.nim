import ../ecs/ecs
import ../assets

type
   SpriteComponent* = ref object of Component
      sprite*: Sprite
