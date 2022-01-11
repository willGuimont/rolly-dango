import ../ecs/ecs

type
   PositionComponent* = ref object of Component
      x*: int8
      y*: int8
      z*: int8

