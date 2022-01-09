import std/unittest
import cart/components/inputcomponent
import cart/components/positioncomponent
import cart/components/physiccomponent
import cart/components/observercomponent
import cart/ecs/ecs
import cart/events/eventqueue

suite "observercomponent":
    test "When entity in front of observer, sends a message":
        var reg: Registry = newRegistry()

        var testEntity = reg.newEntity()
        var testPositionComponent: PositionComponent = PositionComponent(x: 1,
                y: 0, z: 0)
        var topic = newTopic[ObserverPunchMessage]()
        var queue = newEventQueue[ObserverPunchMessage]()
        queue.followTopic(topic)

        var testObserverComponent = ObserverComponent(positionObserving: @[
                testPositionComponent],
            physicsTopic: topic, observerType: ObserverType.otPunchRight)

        reg.addComponent(testEntity, testPositionComponent)
        reg.addComponent(testEntity, testObserverComponent)
        reg.addComponent(testEntity, PhysicsComponent())

        reg.processObservers()

        check queue.messages()[0].message == opmPunchRight
        check queue.messages()[0].entityObserved == testEntity
        check queue.messages()[0].positionObserved == testPositionComponent

