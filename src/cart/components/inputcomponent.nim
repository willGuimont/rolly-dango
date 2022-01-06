import ../ecs/ecs
import ../input/gamepad
import ../components/physiccomponent
import ../events/eventqueue
import ../wasm4

type InputComponent* = ref object of Component
    gamepad*: Gamepad
    physicTopic: MovementTopic

proc processInput*(reg: Registry) =
    for (inputCompoment) in reg.entitiesWithComponents(InputComponent):
        trace($typeof(inputCompoment))
        if inputComponent.gamepad.isLeft():
            echo "a"
                # elif inputComponent.gamepad.isRight():
                #     echo "a"
                # elif inputComponent.gamepad.isFront():
                #     echo "a"
                # elif inputComponent.gamepad.isBack():
                #     echo "a"
