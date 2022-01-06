import std/unittest
import std/options
import cart/state/statemachine

type
  MockState = ref object of BaseState
    wasCalled: bool
    nextStateAfterExecute: Option[BaseState]

proc newMockState(next: Option[BaseState] = none(BaseState)): MockState =
  return MockState(wasCalled: false, nextStateAfterExecute: next)

method execute(s: MockState) =
  s.wasCalled = true
  s.nextState = s.nextStateAfterExecute

suite "statemachine":
  test "QuitState makes the state machine finish":
    var sm = newStateMachine(QuitState())

    check sm.isFinished()

  test "machine doesn't finish on other states":
    var sm = newStateMachine(newMockState())

    check not sm.isFinished()

  test "can run a state":
    var s = newMockState()
    var sm = newStateMachine(s)

    sm.execute()

    check s.wasCalled

  test "stays on some state when no next state":
    var nextState = newMockState()
    var s = newMockState()
    var sm = newStateMachine(s)

    sm.execute()
    sm.transition()
    sm.execute()

    check not nextState.wasCalled

  test "can transition to another state":
    var nextState = newMockState()
    var s = newMockState(some(cast[BaseState](nextState)))
    var sm = newStateMachine(s)

    sm.execute()
    sm.transition()
    sm.execute()

    check nextState.wasCalled
