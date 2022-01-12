import ../ecs/ecs
import positioncomponent
import ../events/eventqueue

type
    ObserverType* = enum otPunchRight, otPunchFront, otPunchLeft, otPunchBack
    ObserverPunchMessageEnum* = enum opmPunchRight, opmPunchFront, opmPunchLeft, opmPunchBack
    ObserverPunchMessage* = object
        message*: ObserverPunchMessageEnum
        entityObserved*: uint32
        positionObserved*: PositionComponent
    ObserverPunchTopic* = Topic[ObserverPunchMessage]
    ObserverPunchEventQueue* = EventQueue[ObserverPunchMessage]
    ObserverComponent* = ref object of Component
        positionObserving*: seq[PositionComponent]
        physicsTopic*: ObserverPunchTopic
        observerType*: ObserverType
