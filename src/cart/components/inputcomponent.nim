import ../ecs/ecs
import ../input/gamepad
import ../components/physiccomponent
import ../state/levelstateevents
import ../events/eventqueue

type InputComponent* = ref object of Component
    gamepad*: ptr Gamepad
    physicTopic*: MovementTopic
    gameTopic*: GameTopic

proc processInput*(reg: Registry) =
    for (ic) in reg.entitiesWithComponents(InputComponent):
        if ic.gamepad[].isLeft():
            ic.physicTopic.sendMessage(mmMoveLeft)
        elif ic.gamepad[].isRight():
            ic.physicTopic.sendMessage(mmMoveRight)
        elif ic.gamepad[].isFront():
            ic.physicTopic.sendMessage(mmMoveFront)
        elif ic.gamepad[].isBack():
            ic.physicTopic.sendMessage(mmMoveBack)
        elif ic.gamepad[].isButton1:
            ic.gameTopic.sendMessage(gmReset)
