import ../ecs/ecs
import ../input/gamepad

type InputComponent* = ref object of Component
  gamepad*: Gamepad
