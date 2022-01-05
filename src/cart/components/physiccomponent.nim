import std/options
import ../events/eventqueue
import ../ecs/ecs
import ../components/positioncomponent
import ../components/worldtilecomponent

type
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

proc physicsSystem*(reg: Registry) =
    for (pos, phy) in reg.entitiesWithComponents(PositionComponent,
            PhysicsComponent):
        pos.x += phy.velocity.x
        pos.y += phy.velocity.y
        let entityUnder = reg.standingOn(pos)
        if entityUnder.isSome():
            let entity = entityUnder.get()
            if reg.hasComponent[:WorldTileComponent](entity):
                let velDelta = getTileVelocity(reg.getComponent[:
                        WorldTileComponent](entity))
                phy.velocity.x += velDelta.x
                phy.velocity.y += velDelta.y
        else:
            pos.z.dec
