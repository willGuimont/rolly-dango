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
    MovementTopic = Topic[MovementMessage]
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
    case getDirection(phy.velocity)
    of Direction.dRight:
        return Velocity(x: 0, y: -1)
    of Direction.dFront:
        return Velocity(x: -1, y: 0)
    of Direction.dLeft:
        return Velocity(x: 0, y: 1)
    of Direction.dBack:
        return Velocity(x: 1, y: 0)
    else:
        return Velocity(x: 0, y: 0)

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

proc sign(value: int8): int8 =
    if value > 0:
        return 1
    if value < 0:
        return -1
    return 0

proc physicsSystem*(reg: Registry) =
    for (pos, phy) in reg.entitiesWithComponents(PositionComponent,
            PhysicsComponent):
        pos.x += sign(phy.velocity.x)
        pos.y += sign(phy.velocity.y)

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

