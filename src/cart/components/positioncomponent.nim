import ../ecs/ecs

type
   PositionComponent* = ref object of Component
      x*: int8
      y*: int8
      z*: int8

proc `==`(a, b: PositionComponent): bool =
   return a.x == b.x and a.y == b.y and a.z == b.z

proc `!=`(a, b: PositionComponent): bool =
   if a == b:
      return false
   return true
