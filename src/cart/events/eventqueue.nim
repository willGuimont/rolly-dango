import std/options
import cart/events/pubsub

type
  EventQueue*[T] = ref object
    queue: seq[T]
  Topic*[T] = Publisher[T]

proc messages*[T](queue: EventQueue[T]): seq[T] =
  result = queue.queue

proc popMessage*[T](queue: EventQueue[T]): Option[T] =
  if len(queue.queue) > 0:
    result = some(queue.queue[0])
    queue.queue.delete(0)
  else:
    result = none(T)

proc newTopic*[T](): Topic[T] =
  result = Topic[T]()

proc newEventQueue*[T](): EventQueue[T] =
  result = new(EventQueue[T])

proc followTopic*[T](eventQueue: EventQueue[T], topic: var Topic[T]) =
  proc queueMessage(event: T) =
    eventQueue[].queue.add(event)
  topic.addSubscriber(queueMessage)

proc sendMessage*[T](topic: Topic[T], message: T) =
  topic.notifySubscribers(message)
