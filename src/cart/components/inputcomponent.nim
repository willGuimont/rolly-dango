import ../ecs/ecs
import ../input/gamepad
import ../input/wasm4gamepad

type InputComponent* = ref object of Component
  gamepad*: Wasm4Gamepad
