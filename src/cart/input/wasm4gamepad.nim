import ../wasm4

type Wasm4Gamepad* = ref object
    gamepad: ptr uint8

proc getNewGamepad*(newGamepad: ptr uint8): Wasm4Gamepad =
    return Wasm4Gamepad(gamepad: newGamepad)

proc isLeft*(wasm4Gamepad: Wasm4Gamepad): bool =
    return bool(wasm4Gamepad.gamepad[] and BUTTON_LEFT)

proc isRight*(wasm4Gamepad: Wasm4Gamepad): bool =
    return bool(wasm4Gamepad.gamepad[] and BUTTON_RIGHT)

proc isFront*(wasm4Gamepad: Wasm4Gamepad): bool =
    return bool(wasm4Gamepad.gamepad[] and BUTTON_UP)

proc isBack*(wasm4Gamepad: Wasm4Gamepad): bool =
    return bool(wasm4Gamepad.gamepad[] and BUTTON_DOWN)
