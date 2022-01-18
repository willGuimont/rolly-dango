import std/options
import ../events/eventqueue
import ../ecs/ecs
import positioncomponent
import worldtilecomponent
import observercomponent
import ../wasm4

type
    Direction* = enum
        dNone, dRight, dFront, dLeft, dBack
    Velocity* = object
        x*: int8
        y*: int8
    MovementMessage* = enum mmMoveRight, mmMoveFront, mmMoveLeft, mmMoveBack
    MovementTopic* = Topic[MovementMessage]
    MovementEventQueue* = EventQueue[MovementMessage]
    PhysicsComponent* = ref object of Component
        velocity*: Velocity
        eventQueue*: MovementEventQueue
        energy*: int8

const PUNCH_VELOCITY_INCREASE: int8 = 4
let observerEventQueue*: ObserverPunchEventQueue = ObserverPunchEventQueue()

proc newPhysicsComponent*(velocity: Velocity): PhysicsComponent =
    return PhysicsComponent(velocity: velocity, eventQueue: MovementEventQueue(), energy: 0)

proc getTileAt(reg: Registry, x: int8, y: int8, z: int8): Option[Entity] =
    for e in reg.entitiesWith(PositionComponent, WorldTileComponent):
        let tpos = reg.getComponent[:PositionComponent](e)
        if tpos.x == x and tpos.y == y and tpos.z == z:
            return some(e)
    return none(Entity)

proc standingOn(reg: Registry, pos: PositionComponent): Option[Entity] =
    return reg.getTileAt(pos.x, pos.y, pos.z-1)

proc getMirrorAt(reg: Registry, x: int8, y: int8, z: int8,
        entity: Entity): Option[Entity] =
    for e in reg.entitiesWith(PositionComponent, WorldTileComponent):
        let (tpos, twtt) = reg.getComponents(e, PositionComponent, WorldTileComponent)
        if e != entity and tpos.x == x and tpos.y == y and tpos.z == z and (
                twtt.tileType == wttMirrorRight or twtt.tileType ==
                wttMirrorFront or
                twtt.tileType == wttMirrorLeft or twtt.tileType ==
                wttMirrorBack):
            return some(e)
    return none(Entity)

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

proc getPunchBlockDirection(tileType: WorldTileComponent): Direction =
    case tileType.tileType
    of wttPunchRight:
        return dRight
    of wttPunchFront:
        return dFront
    of wttPunchLeft:
        return dLeft
    of wttPunchBack:
        return dBack
    else: return dNone

proc getSlopeDirection(tileType: WorldTileComponent): Direction =
    case tileType.tileType
    of wttSlopeRight:
        return dRight
    of wttSlopeFront:
        return dFront
    of wttSlopeLeft:
        return dLeft
    of wttSlopeBack:
        return dBack
    else: return dNone

proc processTileFriction(reg: Registry, pos: PositionComponent,
        phy: PhysicsComponent) =
    let entityUnder = reg.standingOn(pos)
    if entityUnder.isSome():
        let tileType = reg.getComponent[:WorldTileComponent](entityUnder.get()).tileType
        if tileType == WorldTileType.wttTile or tileType ==
                WorldTileType.wttStatic:
            let vel = tileFriction(phy)
            phy.velocity.x += vel.x
            phy.velocity.y += vel.y

proc processGravity(reg: Registry, pos: PositionComponent) =
    let entityUnder = reg.standingOn(pos)
    if entityUnder.isNone():
        pos.z.dec

proc isSlope(tileType: WorldTileType): bool =
    return tileType == wttSlopeRight or tileType == wttSlopeFront or tileType ==
            wttSlopeLeft or tileType == wttSlopeBack

proc moveOneTile(reg: Registry, entity: Entity, pos: PositionComponent,
        phy: PhysicsComponent, direction: Direction, tileMove: int8) =
    let entityHere = reg.getMirrorAt(pos.x, pos.y, pos.z, entity)
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
        let entityUnder = reg.standingOn(pos)
        let directionTuple = getDirectionTuple(direction)
        if entityUnder.isSome() and getSlopeDirection(reg.getComponent[:
                WorldTileComponent](entityUnder.get())) == direction:
            if reg.getTileAt(pos.x+directionTuple.x, pos.y+directionTuple.y,
                    +pos.z-1).isNone():
                pos.x += directionTuple.x
                pos.y += directionTuple.y

        else:
            pos.x += directionTuple.x
            pos.y += directionTuple.y
    else:
        let forwardTileType = reg.getComponent[:WorldTileComponent](
                entityForward.get()).tileType
        if forwardTileType == WorldTileType.wttSlopeRight and direction ==
                Direction.dLeft:
            let tileAbove = reg.getTileAt(pos.x, pos.y-1, pos.z+1)
            if tileAbove.isSome():
                let (abovePos, abovePhy) = reg.getComponents(
                        tileAbove.get(), PositionComponent, PhysicsComponent)
                moveOneTile(reg, tileAbove.get(), abovePos, abovePhy, direction, tileMove-1)
                if reg.getTileAt(pos.x, pos.y-1, pos.z+1).isNone():
                    pos.y.dec
                    pos.z.inc
                    phy.velocity.y += 1
                    phy.energy += 1
            else:
                pos.y.dec
                pos.z.inc
                phy.velocity.y += 1
                phy.energy += 1
        elif forwardTileType == WorldTileType.wttSlopeFront and direction ==
                Direction.dBack:
            let tileAbove = reg.getTileAt(pos.x-1, pos.y, pos.z+1)
            if tileAbove.isSome():
                let (abovePos, abovePhy) = reg.getComponents(
                        tileAbove.get(), PositionComponent, PhysicsComponent)
                moveOneTile(reg, tileAbove.get(), abovePos, abovePhy, direction, tileMove-1)
                if reg.getTileAt(pos.x-1, pos.y, pos.z+1).isNone():
                    pos.x.dec
                    pos.z.inc
                    phy.velocity.x += 1
                    phy.energy += 1
            else:
                pos.x.dec
                pos.z.inc
                phy.velocity.x += 1
                phy.energy += 1
        elif forwardTileType == WorldTileType.wttSlopeLeft and direction ==
                Direction.dRight:
            let tileAbove = reg.getTileAt(pos.x, pos.y+1, pos.z+1)
            if tileAbove.isSome():
                let (abovePos, abovePhy) = reg.getComponents(
                        tileAbove.get(), PositionComponent, PhysicsComponent)
                moveOneTile(reg, tileAbove.get(), abovePos, abovePhy, direction, tileMove-1)
                if reg.getTileAt(pos.x, pos.y+1, pos.z+1).isNone():
                    pos.y.inc
                    pos.z.inc
                    phy.velocity.y -= 1
                    phy.energy += 1
            else:
                pos.y.inc
                pos.z.inc
                phy.velocity.y -= 1
                phy.energy += 1
        elif forwardTileType == WorldTileType.wttSlopeBack and direction ==
                Direction.dFront:
            let tileAbove = reg.getTileAt(pos.x+1, pos.y, pos.z+1)
            if tileAbove.isSome():
                let (abovePos, abovePhy) = reg.getComponents(
                        tileAbove.get(), PositionComponent, PhysicsComponent)
                moveOneTile(reg, tileAbove.get(), abovePos, abovePhy, direction, tileMove-1)
                if reg.getTileAt(pos.x+1, pos.y, pos.z+1).isNone():
                    pos.x.inc
                    pos.z.inc
                    phy.velocity.x -= 1
                    phy.energy += 1
            else:
                pos.x.inc
                pos.z.inc
                phy.velocity.x -= 1
                phy.energy += 1
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
                    moveOneTile(reg, entityForward.get(), forwardPos,
                            forwardPhy, direction, tileMove-1)
                    let directionTuple = getDirectionTuple(direction)
                    if reg.getForward(pos, direction).isNone():
                        pos.x += directionTuple.x
                        pos.y += directionTuple.y
                    phy.velocity = Velocity(x: 0, y: 0)
            else:
                phy.velocity = Velocity(x: 0, y: 0)
    if reg.hasAllComponents(entity, ObserverComponent, PositionComponent,
            WorldTileComponent):
        let (pos, obs, worldTileComponent) = reg.getComponents(entity,
                PositionComponent, ObserverComponent, WorldTileComponent)
        for position in obs.positionObserving:
            let directionTuple = getDirectionTuple(getPunchBlockDirection(worldTileComponent))
            position.x = pos.x + directionTuple.x
            position.y = pos.y + directionTuple.y
            position.z = pos.z

proc processMirror(reg: Registry, entity: Entity, pos: PositionComponent,
        phy: PhysicsComponent) =
    let entityHere = reg.getMirrorAt(pos.x, pos.y, pos.z, entity)
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

proc processVelocityMovement(reg: Registry, entity: Entity,
        pos: PositionComponent, phy: PhysicsComponent) =
    processMirror(reg, entity, pos, phy)
    let direction = getDirection(phy.velocity)
    moveOneTile(reg, entity, pos, phy, direction, getAbsoluteVelocity(phy.velocity))

proc playMoveSound() =
    tone(320 or (540 shl 16), (0 shl 24) or (12 shl 16) or (0 shl 0) or (
            0 shl 8), 25, TONE_TRIANGLE)

proc processEventQueue(reg: Registry, entity: Entity, pos: PositionComponent,
        phy: PhysicsComponent) =
    if phy.eventQueue != nil:
        let direction = getDirection(phy.velocity)
        if direction == dNone and reg.standingOn(pos).isSome():
            let m = phy.eventQueue.popMessage()
            if m.isSome():
                playMoveSound()
                case (m.get())
                of mmMoveBack:
                    moveOneTile(reg, entity, pos, phy, dBack, 1)
                of mmMoveFront:
                    moveOneTile(reg, entity, pos, phy, dFront, 1)
                of mmMoveLeft:
                    moveOneTile(reg, entity, pos, phy, dLeft, 1)
                of mmMoveRight:
                    moveOneTile(reg, entity, pos, phy, dRight, 1)
        phy.eventQueue.clearQueue()

proc processMovement(reg: Registry, entity: Entity, pos: PositionComponent,
        phy: PhysicsComponent) =
    reg.processEventQueue(entity, pos, phy)
    reg.processVelocityMovement(entity, pos, phy)

proc processPunch(reg: Registry, direction: Direction, pos: PositionComponent,
        phy: PhysicsComponent) =
    case direction
    of dRight:
        phy.velocity = Velocity(x: 0, y: PUNCH_VELOCITY_INCREASE)
    of dFront:
        phy.velocity = Velocity(x: PUNCH_VELOCITY_INCREASE, y: 0)
    of dLeft:
        phy.velocity = Velocity(x: 0, y: -PUNCH_VELOCITY_INCREASE)
    of dBack:
        phy.velocity = Velocity(x: -PUNCH_VELOCITY_INCREASE, y: 0)
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
    for entity in reg.entitiesWith(PositionComponent,
            PhysicsComponent):
        let (pos, phy) = reg.getComponents(entity, PositionComponent, PhysicsComponent)

        processMovement(reg, entity, pos, phy)
        processTileFriction(reg, pos, phy)
        processGravity(reg, pos)

        if getAbsoluteVelocity(phy.velocity) == 0:
            phy.energy = pos.z-1
        let entityUnder = reg.standingOn(pos)
        if entityUnder.isSome():
            let entityU = entityUnder.get()
            let direction = getDirection(phy.velocity)
            let slopeDirection = getSlopeDirection(reg.getComponent[:
                    WorldTileComponent](entityU))
            if phy.energy != 0 and slopeDirection != dNone and (direction ==
                    dNone or direction == slopeDirection):
                let velDelta = getTileVelocity(reg.getComponent[:
                        WorldTileComponent](entityU))
                phy.velocity.x += velDelta.x * phy.energy
                phy.velocity.y += velDelta.y * phy.energy
                phy.energy = 0
