import ../events/eventqueue

type
    GameMessage* = enum gmReset, gmNextLevel
    GameTopic* = Topic[GameMessage]
    GameEventQueue* = EventQueue[GameMessage]
