import std/options

type
    BaseState* = ref object of RootObj
        nextState*: Option[BaseState]
    QuitState* = ref object of BaseState
    StateMachine* = object
        currentState: BaseState

method execute(s: BaseState) {.base.} =
    discard

proc newStateMachine*(s: BaseState): StateMachine =
    return StateMachine(currentState: s)

proc execute*(sm: var StateMachine) =
    sm.currentState.execute()

proc transition*(sm: var StateMachine) =
    if sm.currentState.nextState.isSome():
        sm.currentState = sm.currentState.nextState.get()

proc isFinished*(sm: StateMachine): bool =
    return sm.currentState of QuitState
