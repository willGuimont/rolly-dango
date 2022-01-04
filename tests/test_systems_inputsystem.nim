import unittest
import cart/systems/inputsystem
import cart/input/wasm4gamepad
import cart/components/positioncomponent
import cart/components/inputcomponent
import cart/ecs/ecs

suite "inputsystem":
    test "when gamepad presses left, move entity to the left":
        var reg: Registry = newRegistry()

        var gamepad: uint8 = uint8(0b000010000)
        var testEntity = reg.newEntity()
        var testPositionComponent: PositionComponent = PositionComponent(x: 1,
                y: 0, z: 0)
        var testInputComponent: InputComponent = InputComponent(
            gamepad: getNewGamepad(addr gamepad))
        reg.addComponent(testEntity, testPositionComponent)
        reg.addComponent(testEntity, testInputComponent)
        processInput(reg)

        let (positionComponent) = reg.getComponents(testEntity, PositionComponent)
        assert positionComponent.x == 2
