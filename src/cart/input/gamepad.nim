import ../wasm4

type Gamepad* = ref object
    lastGamepad: uint8
    gamepad: uint8

proc getNewGamepad*(newGamepad: uint8): Gamepad =
    return Gamepad(gamepad: newGamepad)

proc updateGamepad*(theGamepad: Gamepad) =
    var currentGamepad = GAMEPAD1[]
    theGamepad.gamepad = currentGamepad and (
            currentGamepad xor theGamepad.lastGamepad);
    theGamepad.lastGamepad = currentGamepad

proc isLeft*(theGamepad: Gamepad): bool =
    return bool(theGamepad.gamepad and BUTTON_LEFT)

proc isRight*(theGamepad: Gamepad): bool =
    return bool(theGamepad.gamepad and BUTTON_RIGHT)

proc isFront*(theGamepad: Gamepad): bool =
    return bool(theGamepad.gamepad and BUTTON_UP)

proc isBack*(theGamepad: Gamepad): bool =
    return bool(theGamepad.gamepad and BUTTON_DOWN)
