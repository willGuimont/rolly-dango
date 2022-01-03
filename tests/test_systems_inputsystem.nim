import unittest
import cart/systems/inputsystem
import cart/input/gamepad
import cart/components/positioncomponent
import cart/components/inputcomponent
import cart/ecs/ecs

type TestGamepad = ref object of Gamepad

method isLeft*(this: TestGamepad): bool =
    echo "TestGamepad called"
    return true

suite "inputsystem":
    test "when gamepad presses left, move entity to the left":
        var reg: Registry = newRegistry()

        var testEntity = reg.newEntity()
        var testPositionComponent: PositionComponent = PositionComponent(x: 1,
                y: 0, z: 0)
        var testInputComponent: InputComponent = InputComponent(
            gamepad: TestGamepad())
        reg.addComponent(testEntity, testPositionComponent)
        reg.addComponent(testEntity, testInputComponent)
        processInput(reg)

        let (positionComponent) = reg.getComponents(testEntity, PositionComponent)
        assert positionComponent.x == 0
