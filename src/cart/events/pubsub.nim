type
    Subscriber*[T] = proc(event: T)
    Publisher*[T] = object
        subscribers: seq[Subscriber[T]]

proc newPublisher*[T](subs: varargs[Subscriber[T]]): Publisher[T] =
    result = Publisher[T](subscribers: @subs)

proc addSubscriber*[T](pub: var Publisher[T], sub: Subscriber[T]) =
    pub.subscribers.add(sub)

proc notifySubscribers*[T](pub: Publisher[T], event: T) =
    for sub in pub.subscribers:
        sub(event)
