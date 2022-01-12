import ../components/positioncomponent
import ../components/physiccomponent
import ../components/observercomponent
import ../events/eventqueue
import ../ecs/ecs

proc getObserverMessage(observerType: ObserverType): ObserverPunchMessageEnum =
    case observerType
    of otPunchRight:
        return ObserverPunchMessageEnum.opmPunchRight
    of otPunchFront:
        return ObserverPunchMessageEnum.opmPunchFront
    of otPunchLeft:
        return ObserverPunchMessageEnum.opmPunchLeft
    of otPunchBack:
        return ObserverPunchMessageEnum.opmPunchBack

proc isIn(pos: PositionComponent, positions: seq[PositionComponent]): bool =
    for position in positions:
        if position.x == pos.x and position.y == pos.y and position.z == pos.z:
            return true
    return false

proc processObserver(observer: ObserverComponent, reg: Registry) =
    for entity in reg.entitiesWith(PhysicsComponent, PositionComponent):
        let pos = reg.getComponent[:PositionComponent](entity)
        if pos.isIn(observer.positionObserving):
            observer.physicsTopic.sendMessage(ObserverPunchMessage(
                    message: observer.observerType.getObserverMessage(),
                    entityObserved: entity, positionObserved: pos))

proc processObservers*(reg: Registry) =
    for entity in reg.entitiesWith(ObserverComponent):
        processObserver(reg.getComponent[:ObserverComponent](entity), reg)
