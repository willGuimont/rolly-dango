import ../ecs/ecs
import positioncomponent
import physiccomponent
import ../events/eventqueue

type 
    ObserverType* = enum otPunchRight, otPunchFront, otPunchLeft, otPunchBack
    ObserverComponent* = ref object of Component
        positionObserving: seq[PositionComponent]
        physicsTopic: ObserverPunchTopic
        observerType: ObserverType

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

proc processObserver*(observer: ObserverComponent, reg:Registry) = 
    for entity in reg.entitiesWith(PhysicsComponent, PositionComponent):
        let pos = reg.getComponent[:PositionComponent](entity)
        if pos in observer.positionObserving:
            observer.physicsTopic.sendMessage(ObserverPunchMessage(message:observer.observerType.getObserverMessage(), entityObserved:entity, positionObserved:pos))
