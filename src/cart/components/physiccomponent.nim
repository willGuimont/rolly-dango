import std/options
import ../ecs/ecs
import ../components/positioncomponent
import ../components/worldtilecomponent

type
    PhysicsComponent* = ref object of Component

proc standingOn(reg: Registry, pos: PositionComponent): Option[Entity] =
    for e in reg.entitiesWith(PositionComponent, WorldTileComponent):
        let tpos = reg.getComponent[:PositionComponent](e)
        if tpos.x == pos.x and tpos.y == pos.y and tpos.z == pos.z - 1:
            return some(e)
    return none(Entity)

proc physicsSystem*(reg: Registry) =
    for (pos, _) in reg.entitiesWithComponents(PositionComponent,
            PhysicsComponent):
        let entityUnder = reg.standingOn(pos)
        if entityUnder.isNone():
            pos.z.dec
