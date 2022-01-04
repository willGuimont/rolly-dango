import ../ecs/ecs
import ../components/positioncomponent
import ../components/worldtilecomponent

type
    PhysicsComponent* = ref object of Component

proc physicsSystem*(reg: Registry) =
    for (pos, _) in reg.entitiesWithComponents(PositionComponent,
            PhysicsComponent):
        var floorUnder = false
        for (tpos, _) in reg.entitiesWithComponents(PositionComponent,
                WorldTileComponent):
            if tpos.x == pos.x and tpos.y == pos.y and tpos.z == pos.z - 1:
                floorUnder = true
                break
        if not floorUnder:
            pos.z.dec
