import std/options
import ../events/eventqueue
import ../ecs/ecs
import ../assets/sprites
import ../components/spritecomponent
import ../components/positioncomponent
import ../components/physiccomponent
import ../components/inputcomponent
import ../components/worldtilecomponent
import ../components/playercomponent
import ../components/observercomponent
import ../input/gamepad
import levelstateevents

type
    LevelState* = ref object
        nextState*: Option[LevelState]
        needsToTransition: bool
        reg*: Registry
        gamepad: Gamepad
        levelData*: Level[array[500, uint8]]
        wasBuilt*: bool
        eventQueue: GameEventQueue
        gameTopic: Topic[GameMessage]
    StateMachine*[T] = object
        currentState: T

proc newLevelState*(reg: Registry, g: Gamepad, level: Level[array[500, uint8]],
        nextState: Option[LevelState]): LevelState =
    let eventQueue = newEventQueue[GameMessage]()
    var gameTopic = newTopic[GameMessage]()
    eventQueue.followTopic(gameTopic)
    return LevelState(reg: reg, gamepad: g, levelData: level, wasBuilt: false,
            eventQueue: eventQueue, gameTopic: gameTopic, nextState: nextState,
            needsToTransition: false)

proc newLevelList*(reg: Registry, g: Gamepad, levels: seq[Level[array[500,
        uint8]]]): Option[LevelState] =
    if len(levels) == 0:
        return none(LevelState)
    let nextState = newLevelList(reg, g, levels[1..^1])
    return some(newLevelState(reg, g, levels[0], nextState))

proc intToTileType(x: uint8): Option[WorldTileType] =
    case x:
        of 0: none(WorldTileType)
        of 1: some(wttTile)
        of 2: some(wttSlopeFront)
        of 3: some(wttSlopeRight)
        of 4: some(wttSlopeLeft)
        of 5: some(wttSlopeBack)
        of 6: some(wttMirrorFront)
        of 7: some(wttMirrorRight)
        of 8: some(wttMirrorLeft)
        of 9: some(wttMirrorBack)
        of 10: some(wttPunchFront)
        of 11: some(wttPunchRight)
        of 12: some(wttPunchLeft)
        of 13: some(wttPunchBack)
        of 14: some(wttIce)
        of 15: some(wttStarting)
        of 16: some(wttEnding)
        else: none(WorldTileType)

proc intToSprite(x: uint8): Option[Sprite] =
    case x:
        of 0: none(Sprite)
        of 1: some(tileSprite)
        of 2: some(slopeFrontSprite)
        of 3: some(slopeRightSprite)
        of 4: some(slopeLeftSprite)
        of 5: some(slopeBackSprite)
        of 6: some(mirrorFrontSprite)
        of 7: some(mirrorRightSprite)
        of 8: some(mirrorLeftSprite)
        of 9: some(mirrorBackSprite)
        of 10: some(punchBlockFrontSprite)
        of 11: some(punchBlockRightSprite)
        of 12: some(punchBlockLeftSprite)
        of 13: some(punchBlockBackSprite)
        of 14: some(iceSprite)
        of 15: some(tileSprite)
        of 16: some(cupSprite)
        else: none(Sprite)

proc createDangoAt(s: LevelState, i, j, k: int8) =
    var dango = s.reg.newEntity()
    var inputTopic = newTopic[MovementMessage]()
    let phyComponent = newPhysicsComponent(Velocity(x: 0, y: 0))
    phyComponent.eventQueue.followTopic(inputTopic)
    s.reg.addComponent(dango, SpriteComponent(sprite: dangoSprite))
    s.reg.addComponent(dango, PositionComponent(x: i, y: j, z: k))
    s.reg.addComponent(dango, InputComponent(gamepad: s.gamepad,
        physicTopic: inputTopic, gameTopic: s.gameTopic))
    s.reg.addComponent(dango, phyComponent)
    s.reg.addComponent(dango, PlayerComponent(gameTopic: s.gameTopic))
    s.reg.addComponent(dango, WorldTileComponent(tileType: wttTile))

proc addPunchObserver(reg: Registry, entity: Entity, punchType: ObserverType, i,
        j, k: int8) =
    var observerTopic = newTopic[ObserverPunchMessage]()
    observerEventQueue.followTopic(observerTopic)
    var observing: seq[PositionComponent]
    case punchType
    of otPunchRight:
        observing.add(PositionComponent(x: i, y: j+1, z: k))
    of otPunchFront:
        observing.add(PositionComponent(x: i+1, y: j, z: k))
    of otPunchLeft:
        observing.add(PositionComponent(x: i, y: j-1, z: k))
    of otPunchBack:
        observing.add(PositionComponent(x: i-1, y: j, z: k))
    var observerComponent = ObserverComponent(positionObserving: observing,
            physicsTopic: observerTopic, observerType: punchType)

    reg.addComponent(entity, observerComponent)

proc buildLevel*(s: LevelState) =
    let level = s.levelData
    let x = level.x
    let y = level.y
    let z = level.z
    for i in 0..<x:
        for j in 0..<y:
            for k in 0..<z:
                let idx = i + j * x + k * x * y
                let tileType = level.data[idx]
                let ott = intToTileType(tileType)
                let oSprite = intToSprite(tileType)
                if ott.isSome() and oSprite.isSome():
                    let tt = ott.get()
                    var e = s.reg.newEntity()
                    s.reg.addComponent(e, SpriteComponent(sprite: oSprite.get()))
                    s.reg.addComponent(e, PositionComponent(x: int8(i), y: int8(
                            j), z: int8(k)))
                    s.reg.addComponent(e, PhysicsComponent())
                    if tt == wttStarting:
                        s.createDangoAt(int8(i), int8(j), int8(k + 1))
                        s.reg.addComponent(e, WorldTileComponent(
                                tileType: wttTile))
                    elif tt == wttPunchRight:
                        addPunchObserver(s.reg, e, otPunchRight, int8(i), int8(
                                j), int8(k))
                        s.reg.addComponent(e, WorldTileComponent(tileType: tt))
                    elif tt == wttPunchFront:
                        addPunchObserver(s.reg, e, otPunchFront, int8(i), int8(
                                j), int8(k))
                        s.reg.addComponent(e, WorldTileComponent(tileType: tt))
                    elif tt == wttPunchLeft:
                        addPunchObserver(s.reg, e, otPunchLeft, int8(i), int8(
                                j), int8(k))
                        s.reg.addComponent(e, WorldTileComponent(tileType: tt))
                    elif tt == wttPunchBack:
                        addPunchObserver(s.reg, e, otPunchBack, int8(i), int8(
                                j), int8(k))
                        s.reg.addComponent(e, WorldTileComponent(tileType: tt))
                    else:
                        s.reg.addComponent(e, WorldTileComponent(tileType: tt))

proc execute*(s: LevelState) =
    if not s.wasBuilt:
        s.reg.destroyAllEntity()
        s.buildLevel()
        s.wasBuilt = true
    let m = s.eventQueue.popMessage()
    if m.isSome():
        case m.get()
        of gmReset:
            s.wasBuilt = false
        of gmNextLevel:
            s.needsToTransition = true

proc newStateMachine*[T](s: T): StateMachine[T] =
    return StateMachine[T](currentState: s)

proc execute*[T](sm: var StateMachine[T]) =
    sm.currentState.execute()

proc transition*(sm: var StateMachine) =
    if sm.currentState.needsToTransition and sm.currentState.nextState.isSome():
        sm.currentState = sm.currentState.nextState.get()

proc isFinished*(sm: StateMachine): bool =
    return sm.currentState.needsToTransition and
            sm.currentState.nextState.isNone()
