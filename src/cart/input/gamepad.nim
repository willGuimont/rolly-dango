type
    Gamepad* = ref object of RootObj

method isLeft*(this: Gamepad): bool {.base.} =
    return false

method isRight*(this: Gamepad): bool {.base.} =
    return false

method isFront*(this: Gamepad): bool {.base.} =
    return false

method isBack*(this: Gamepad): bool {.base.} =
    return false
