import ../ecs/ecs
import ../components/inputcomponent
import ../components/positioncomponent
import ../input/gamepad

proc moveLeft(positionComponent: PositionComponent) =
    positionComponent.x -= 1

proc moveRight(positionComponent: PositionComponent) =
    positionComponent.x += 1

proc moveFront(positionComponent: PositionComponent) =
    positionComponent.y += 1

proc moveBack(positionComponent: PositionComponent) =
    positionComponent.y -= 1

proc move*(reg: Registry) =
    if reg != nil:
        for entity in reg.entitiesWith(InputComponent):
            let (inputComponent, positionComponent) = reg.getComponents(entity,
                    InputComponent, PositionComponent)
            if inputComponent.gamepad.isLeft:
                moveLeft(positionComponent)
            elif inputComponent.gamepad.isRight:
                moveRight(positionComponent)
            elif inputComponent.gamepad.isFront:
                moveFront(positionComponent)
            elif inputComponent.gamepad.isBack:
                moveBack(positionComponent)
