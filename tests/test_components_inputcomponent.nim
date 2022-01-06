import std/unittest
import cart/components/inputcomponent
import cart/components/positioncomponent
import cart/components/physiccomponent
import cart/input/gamepad
import cart/ecs/ecs
import cart/events/eventqueue

suite "inputsystem":
    test "when gamepad presses left, move entity to the left":
        var reg: Registry = newRegistry()

        var testEntity = reg.newEntity()
        var testPositionComponent: PositionComponent = PositionComponent(x: 1,
                y: 0, z: 0)
        var topic = newTopic[MovementMessage]()
        var queue = newEventQueue[MovementMessage]()
        queue.followTopic(topic)
        var testInputComponent: InputComponent = InputComponent(
                gamepad: getNewGamepad(uint8(0b000010000)), physicTopic: topic)

        reg.addComponent(testEntity, testPositionComponent)
        reg.addComponent(testEntity, testInputComponent)

        reg.processInput()

        check queue.messages()[0] == mmMoveLeft
