import std/options
import ../events/eventqueue
import ../ecs/ecs
import ../components/positioncomponent
import ../components/worldtilecomponent

type
    Direction* = enum
        dNone, dRight, dFront, dLeft, dBack
    Velocity* = object
        x*: int8
        y*: int8
    MovementMessage* = enum mmMoveRight, mmMoveFront, mmMoveLeft, mmMoveBack
    MovementTopic* = Topic[MovementMessage]
    MovementEventQueue* = EventQueue[MovementMessage]
    ObserverPunchMessageEnum* = enum opmPunchRight, opmPunchFront, opmPunchLeft, opmPunchBack
    ObserverPunchMessage* = object
        message*: ObserverPunchMessageEnum
        entityObserved*: uint32
        positionObserved*: PositionComponent
    ObserverPunchTopic* = Topic[ObserverPunchMessage]
    ObserverPunchEventQueue* = EventQueue[ObserverPunchMessage]
    PhysicsComponent* = ref object of Component
        velocity*: Velocity
        eventQueue*: MovementEventQueue

let PUNCH_VELOCITY_INCREASE: int8 = 3
let observerEventQueue*: ObserverPunchEventQueue = ObserverPunchEventQueue()

proc newPhysicsComponent*(velocity: Velocity): PhysicsComponent =
    return PhysicsComponent(velocity: velocity, eventQueue: MovementEventQueue())

proc getTileAt(reg: Registry, x: int8, y: int8, z: int8): Option[Entity] =
    for e in reg.entitiesWith(PositionComponent, WorldTileComponent):
        let tpos = reg.getComponent[:PositionComponent](e)
        if tpos.x == x and tpos.y == y and tpos.z == z:
            return some(e)
    return none(Entity)

proc standingOn(reg: Registry, pos: PositionComponent): Option[Entity] =
    return reg.getTileAt(pos.x, pos.y, pos.z-1)

proc getDirectionTuple(direction: Direction): tuple[x: int8, y: int8] =
    case direction
    of Direction.dRight:
        return (x: 0'i8, y: 1'i8)
    of Direction.dFront:
        return (x: 1'i8, y: 0'i8)
    of Direction.dLeft:
        return (x: 0'i8, y: -1'i8)
    of Direction.dBack:
        return (x: -1'i8, y: 0'i8)
    else:
        return (x: 0'i8, y: 0'i8)

proc getForward(reg: Registry, pos: PositionComponent,
        direction: Direction): Option[Entity] =
    let directionTuple = getDirectionTuple(direction)
    return reg.getTileAt(pos.x + directionTuple.x, pos.y + directionTuple.y, pos.z)


proc getAbsoluteVelocity(vel: Velocity): int8 =
    return abs(vel.x + vel.y)

proc getDirection(vel: Velocity): Direction =
    #For now we only consider 4 directions
    if vel.x == 0 and vel.y > 0:
        return Direction.dRight
    if vel.x > 0 and vel.y == 0:
        return Direction.dFront
    if vel.x == 0 and vel.y < 0:
        return Direction.dLeft
    if vel.x < 0 and vel.y == 0:
        return Direction.dBack
    if vel.x == 0 and vel.y == 0:
        return Direction.dNone

proc transfertVelocity(vel: Velocity, direction: Direction): Velocity =
    let value = vel.x + vel.y
    case direction
    of dRight:
        return Velocity(x: 0, y: abs(value))
    of dFront:
        return Velocity(x: abs(value), y: 0)
    of dLeft:
        return Velocity(x: 0, y: -abs(value))
    of dBack:
        return Velocity(x: -abs(value), y: 0)
    else:
        return Velocity(x: 0, y: 0)


proc tileFriction(phy: PhysicsComponent): Velocity =
    let direction = getDirectionTuple(getDirection(phy.velocity))
    return Velocity(x: -direction.x, y: -direction.y)

proc getTileVelocity(tile: WorldTileComponent): Velocity =
    case tile.tileType
    of WorldTileType.wttSlopeRight:
        return Velocity(x: 0, y: 1)
    of WorldTileType.wttSlopeFront:
        return Velocity(x: 1, y: 0)
    of WorldTileType.wttSlopeLeft:
        return Velocity(x: 0, y: -1)
    of WorldTileType.wttSlopeBack:
        return Velocity(x: -1, y: 0)
    else:
        return Velocity(x: 0, y: 0)

proc processTileFriction(reg: Registry, pos: PositionComponent,
        phy: PhysicsComponent) =
    let entityUnder = reg.standingOn(pos)
    if entityUnder.isSome():
        if reg.getComponent[:WorldTileComponent](entityUnder.get()).tileType ==
                WorldTileType.wttTile:
            let vel = tileFriction(phy)
            phy.velocity.x += vel.x
            phy.velocity.y += vel.y

proc processGravity(reg: Registry, pos: PositionComponent) =
    let entityUnder = reg.standingOn(pos)
    if entityUnder.isNone():
        pos.z.dec

proc moveOneTile(reg: Registry, pos: PositionComponent, phy: PhysicsComponent,
        direction: Direction, tileMove: int8) =
    let entityHere = reg.getTileAt(pos.x, pos.y, pos.z)
    if entityHere.isSome():
        let hereTileType = reg.getComponent[:WorldTileComponent](
                entityHere.get()).tileType
        if hereTileType == wttMirrorRight and (direction ==
                Direction.dLeft or direction == Direction.dFront):
            return
        if hereTileType == wttMirrorFront and (direction ==
                Direction.dBack or direction == Direction.dLeft):
            return
        if hereTileType == wttMirrorLeft and (direction ==
                Direction.dRight or direction == Direction.dBack):
            return
        if hereTileType == wttMirrorBack and (direction ==
                Direction.dRight or direction == Direction.dFront):
            return
    let entityForward = reg.getForward(pos, direction)
    if entityForward.isNone() or reg.getComponent[:WorldTileComponent](
                entityForward.get()).tileType == wttEnding:
        let directionTuple = getDirectionTuple(direction)
        pos.x += directionTuple.x
        pos.y += directionTuple.y
    else:
        let forwardTileType = reg.getComponent[:WorldTileComponent](
                entityForward.get()).tileType
        if forwardTileType == WorldTileType.wttSlopeRight and direction ==
                Direction.dLeft:
            pos.y.dec
            pos.z.inc
        elif forwardTileType == WorldTileType.wttSlopeFront and direction ==
                Direction.dBack:
            pos.x.dec
            pos.z.inc
        elif forwardTileType == WorldTileType.wttSlopeLeft and direction ==
                Direction.dRight:
            pos.y.inc
            pos.z.inc
        elif forwardTileType == WorldTileType.wttSlopeBack and direction ==
                Direction.dFront:
            pos.x.inc
            pos.z.inc
        elif forwardTileType == WorldTileType.wttMirrorRight and (direction ==
                Direction.dLeft or direction == Direction.dFront):
            let directionTuple = getDirectionTuple(direction)
            pos.x += directionTuple.x
            pos.y += directionTuple.y
        elif forwardTileType == WorldTileType.wttMirrorFront and (direction ==
                Direction.dBack or direction == Direction.dLeft):
            let directionTuple = getDirectionTuple(direction)
            pos.x += directionTuple.x
            pos.y += directionTuple.y
        elif forwardTileType == WorldTileType.wttMirrorLeft and (direction ==
                Direction.dRight or direction == Direction.dBack):
            let directionTuple = getDirectionTuple(direction)
            pos.x += directionTuple.x
            pos.y += directionTuple.y
        elif forwardTileType == WorldTileType.wttMirrorBack and (direction ==
                Direction.dFront or direction == Direction.dRight):
            let directionTuple = getDirectionTuple(direction)
            pos.x += directionTuple.x
            pos.y += directionTuple.y
        else:
            if reg.hasAllComponents(entityForward.get(), PositionComponent,
                    PhysicsComponent) and tileMove > 0:
                let (forwardPos, forwardPhy) = reg.getComponents(
                        entityForward.get(), PositionComponent, PhysicsComponent)
                if reg.getTileAt(forwardPos.x, forwardPos.y,
                        forwardPos.z+1).isNone():
                    moveOneTile(reg, forwardPos, forwardPhy, direction, tileMove-1)
                    let directionTuple = getDirectionTuple(direction)
                    if reg.getForward(pos, direction).isNone():
                        pos.x += directionTuple.x
                        pos.y += directionTuple.y
                    phy.velocity = Velocity(x: 0, y: 0)
            else:
                phy.velocity = Velocity(x: 0, y: 0)

proc processMirror(reg: Registry, pos: PositionComponent,
        phy: PhysicsComponent) =
    let entityHere = reg.getTileAt(pos.x, pos.y, pos.z)
    if entityHere.isSome():

        case reg.getComponent[:WorldTileComponent](
                entityHere.get()).tileType
        of wttMirrorRight, wttMirrorLeft:
            let velx = phy.velocity.x
            phy.velocity.x = phy.velocity.y
            phy.velocity.y = velx
        of wttMirrorFront, wttMirrorBack:
            let velx = phy.velocity.x * -1
            phy.velocity.x = phy.velocity.y * -1
            phy.velocity.y = velx
        else:
            return

proc processVelocityMovement(reg: Registry, pos: PositionComponent,
        phy: PhysicsComponent) =
    processMirror(reg, pos, phy)
    let direction = getDirection(phy.velocity)
    moveOneTile(reg, pos, phy, direction, getAbsoluteVelocity(phy.velocity))

proc processEventQueue(reg: Registry, pos: PositionComponent,
        phy: PhysicsComponent) =
    if phy.eventQueue != nil:
        let direction = getDirection(phy.velocity)
        if direction == dNone and reg.standingOn(pos).isSome():
            let m = phy.eventQueue.popMessage()
            if m.isSome():
                case (m.get())
                of mmMoveBack:
                    moveOneTile(reg, pos, phy, dBack, 1)
                of mmMoveFront:
                    moveOneTile(reg, pos, phy, dFront, 1)
                of mmMoveLeft:
                    moveOneTile(reg, pos, phy, dLeft, 1)
                of mmMoveRight:
                    moveOneTile(reg, pos, phy, dRight, 1)
        phy.eventQueue.clearQueue()

proc processMovement(reg: Registry, pos: PositionComponent,
        phy: PhysicsComponent) =
    reg.processEventQueue(pos, phy)
    reg.processVelocityMovement(pos, phy)

proc processPunch(reg: Registry, direction: Direction, pos: PositionComponent,
        phy: PhysicsComponent) =
    case direction
    of dRight:
        var newVel = transfertVelocity(phy.velocity, dRight)
        newVel.y += PUNCH_VELOCITY_INCREASE
        phy.velocity = newVel
    of dFront:
        var newVel = transfertVelocity(phy.velocity, dFront)
        newVel.x += PUNCH_VELOCITY_INCREASE
        phy.velocity = newVel
    of dLeft:
        var newVel = transfertVelocity(phy.velocity, dLeft)
        newVel.y -= PUNCH_VELOCITY_INCREASE
        phy.velocity = newVel
    of dBack:
        var newVel = transfertVelocity(phy.velocity, dBack)
        newVel.x -= PUNCH_VELOCITY_INCREASE
        phy.velocity = newVel
    else:
        discard

proc processObserverMessage(reg: Registry, message: ObserverPunchMessage) =
    for entity in reg.entitiesWith(PositionComponent, PhysicsComponent):
        if entity == message.entityObserved and reg.getComponent[:
                PositionComponent](entity) == message.positionObserved:
            let (pos, phy) = reg.getComponents(entity, PositionComponent, PhysicsComponent)
            case message.message
            of opmPunchRight:
                processPunch(reg, Direction.dRight, pos, phy)
            of opmPunchFront:
                processPunch(reg, Direction.dFront, pos, phy)
            of opmPunchLeft:
                processPunch(reg, Direction.dLeft, pos, phy)
            of opmPunchBack:
                processPunch(reg, Direction.dBack, pos, phy)

proc processObserver(reg: Registry) =
    var message = observerEventQueue.popMessage()
    while message.isSome():
        reg.processObserverMessage(message.get())
        message = observerEventQueue.popMessage()

proc physicsSystem*(reg: Registry) =
    processObserver(reg)
    for (pos, phy) in reg.entitiesWithComponents(PositionComponent,
            PhysicsComponent):
        if pos.z > 0:
            processMovement(reg, pos, phy)
            processTileFriction(reg, pos, phy)
            processGravity(reg, pos)
            let entityUnder = reg.standingOn(pos)
            if entityUnder.isSome():
                let entity = entityUnder.get()
                if reg.hasComponent[:WorldTileComponent](entity):
                    let velDelta = getTileVelocity(reg.getComponent[:
                            WorldTileComponent](entity))
                    phy.velocity.x += velDelta.x
                    phy.velocity.y += velDelta.y

