import std/unittest
import std/options
import cart/events/eventqueue

suite "eventqueue":
  type
    MessageType = int

  const
    aMessage: MessageType = 123
    anotherMessage: MessageType = 456

  test "no message when no message sent":
    var topic = newTopic[MessageType]()
    var queue = newEventQueue[MessageType]()
    queue.followTopic(topic)

    check len(queue.messages) == 0

  test "can send a message":
    var topic = newTopic[MessageType]()
    var queue = newEventQueue[MessageType]()
    queue.followTopic(topic)

    topic.sendMessage(aMessage)

    check len(queue.messages) == 1
    check aMessage in queue.messages

  test "can send message to multiple queues":
    var topic = newTopic[MessageType]()
    var queue1 = newEventQueue[MessageType]()
    var queue2 = newEventQueue[MessageType]()
    queue1.followTopic(topic)
    queue2.followTopic(topic)

    topic.sendMessage(aMessage)

    check len(queue1.messages) == 1
    check aMessage in queue1.messages
    check len(queue2.messages) == 1
    check aMessage in queue2.messages

  test "can send multiple messages":
    var topic = newTopic[MessageType]()
    var queue = newEventQueue[MessageType]()
    queue.followTopic(topic)

    topic.sendMessage(aMessage)
    topic.sendMessage(anotherMessage)

    check aMessage in queue.messages
    check anotherMessage in queue.messages
    check len(queue.messages) == 2

  test "empty queue returns none":
    var topic = newTopic[MessageType]()
    var queue = newEventQueue[MessageType]()
    queue.followTopic(topic)

    check queue.popMessage == none(MessageType)

  test "can pop messages":
    var topic = newTopic[MessageType]()
    var queue = newEventQueue[MessageType]()
    queue.followTopic(topic)

    topic.sendMessage(aMessage)
    topic.sendMessage(anotherMessage)

    check queue.popMessage == some(aMessage)
    check queue.popMessage == some(anotherMessage)
    check queue.popMessage == none(MessageType)
