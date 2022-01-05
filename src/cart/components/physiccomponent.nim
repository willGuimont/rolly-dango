import std/options
import ../ecs/ecs
import ../components/positioncomponent
import ../components/worldtilecomponent

type
    PhysicsComponent* = ref object of Component
        velocity*: tuple[x: int8, y: int8]

proc standingOn(reg: Registry, pos: PositionComponent): Option[Entity] =
    for e in reg.entitiesWith(PositionComponent, WorldTileComponent):
        let tpos = reg.getComponent[:PositionComponent](e)
        if tpos.x == pos.x and tpos.y == pos.y and tpos.z == pos.z - 1:
            return some(e)
    return none(Entity)

proc physicsSystem*(reg: Registry) =
    for (pos, phy) in reg.entitiesWithComponents(PositionComponent,
            PhysicsComponent):
        pos.x += phy.velocity.x
        pos.y += phy.velocity.y
        let entityUnder = reg.standingOn(pos)
        if entityUnder.isNone():
            pos.z.dec
