import unittest
import std/macros
import std/options
import cart/events/pubsub

macro makeMockedSub(eventType: untyped, name: untyped) =
  let wasCalledWithName = ident($name & "WasCalledWith")
  result = quote do:
    var `wasCalledWithName` = none(`eventType`)
    proc `name`(event: `eventType`) =
      `wasCalledWithName` = some(event)

suite "pubsub":
  type
    EventType = int

  const
    anEvent: EventType = 123

  test "doesn't call sub when not notified":
    makeMockedSub(EventType, sub)
    var pub = newPublisher[EventType]()
    pub.addSubscriber(sub)

    check subWasCalledWith == none(EventType)

  test "calls sub on notify":
    makeMockedSub(EventType, sub)
    var pub = newPublisher[EventType]()
    pub.addSubscriber(sub)

    pub.notifySubscribers(anEvent)

    check subWasCalledWith == some(anEvent)

  test "calls all sub on notify":
    makeMockedSub(EventType, sub1)
    makeMockedSub(EventType, sub2)
    makeMockedSub(EventType, sub3)

    var pub = newPublisher[EventType]()
    pub.addSubscriber(sub1)
    pub.addSubscriber(sub2)
    pub.addSubscriber(sub3)

    pub.notifySubscribers(anEvent)

    check sub1WasCalledWith == some(anEvent)
    check sub2WasCalledWith == some(anEvent)
    check sub3WasCalledWith == some(anEvent)
