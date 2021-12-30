import ../ecs/ecs

type
   PositionComponent* = ref object of Component
      x*: int32
      y*: int32
      z*: int32
