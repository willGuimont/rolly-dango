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
    # TODO make macro to generate constructor for topics and event queue
    MovementTopic* = Topic[MovementMessage]
    MovementEventQueue* = EventQueue[MovementMessage]
    PhysicsComponent* = ref object of Component
        velocity*: Velocity
        eventQueue*: MovementEventQueue

proc standingOn(reg: Registry, pos: PositionComponent): Option[Entity] =
    for e in reg.entitiesWith(PositionComponent, WorldTileComponent):
        let tpos = reg.getComponent[:PositionComponent](e)
        if tpos.x == pos.x and tpos.y == pos.y and tpos.z == pos.z - 1:
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
    for e in reg.entitiesWith(PositionComponent, WorldTileComponent):
        let tpos = reg.getComponent[:PositionComponent](e)
        let directionTuple = getDirectionTuple(direction)
        if tpos.x == pos.x + directionTuple.x and tpos.y == pos.y +
                directionTuple.y and tpos.z == pos.z:
            return some(e)
    return none(Entity)

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
        direction: Direction) =
    let entityForward = reg.getForward(pos, direction)
    if entityForward.isNone():
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
        else:
            phy.velocity = Velocity(x: 0, y: 0)

proc processVelocityMovement(reg: Registry, pos: PositionComponent,
        phy: PhysicsComponent) =
    let direction = getDirection(phy.velocity)
    moveOneTile(reg, pos, phy, direction)

proc processEventQueue(reg: Registry, pos: PositionComponent,
        phy: PhysicsComponent) =
    let direction = getDirection(phy.velocity)
    if direction == dNone and reg.standingOn(pos).isSome():
        let m = phy.eventQueue.popMessage()
        if m.isSome():
            case (m.get())
            of mmMoveBack:
                moveOneTile(reg, pos, phy, dBack)
            of mmMoveFront:
                moveOneTile(reg, pos, phy, dFront)
            of mmMoveLeft:
                moveOneTile(reg, pos, phy, dLeft)
            of mmMoveRight:
                moveOneTile(reg, pos, phy, dRight)

proc processMovement(reg: Registry, pos: PositionComponent,
        phy: PhysicsComponent) =
    reg.processEventQueue(pos, phy)
    reg.processVelocityMovement(pos, phy)
    phy.eventQueue.clearQueue()

proc physicsSystem*(reg: Registry) =
    for (pos, phy) in reg.entitiesWithComponents(PositionComponent,
            PhysicsComponent):
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

