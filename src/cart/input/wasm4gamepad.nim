import gamepad
import ../wasm4

type Wasm4Gamepad* = ref object of Gamepad
    gamepad*: uint8

proc isLeft*(this: Wasm4Gamepad): bool =
    return bool(this.gamepad and BUTTON_LEFT)

proc isRight*(this: Wasm4Gamepad): bool =
    return bool(this.gamepad and BUTTON_RIGHT)

proc isFront*(this: Wasm4Gamepad): bool =
    return bool(this.gamepad and BUTTON_UP)

proc isBack*(this: Wasm4Gamepad): bool =
    return bool(this.gamepad and BUTTON_DOWN)
