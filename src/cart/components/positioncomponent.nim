import ../ecs/ecs

type
   PositionComponent* = ref object of Component
      x*: uint8
      y*: uint8
      z*: uint8
