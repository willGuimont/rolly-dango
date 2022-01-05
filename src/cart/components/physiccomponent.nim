import std/options
import ../ecs/ecs
import ../components/positioncomponent
import ../components/worldtilecomponent

type
    Direction* = enum
        dNone, dRight, dFront, dLeft, dBack
    PhysicsComponent* = ref object of Component
        velocity*: uint8
        direction*: Direction

proc getSlopeDirection(worldTile: WorldTileType): Direction =
    if worldTile == WorldTileType.wttSlopeRight:
        return Direction.dRight
    elif worldTile == WorldTileType.wttSlopeFront:
        return Direction.dFront
    elif worldTile == WorldTileType.wttSlopeLeft:
        return Direction.dLeft
    elif worldTile == WorldTileType.wttSlopeBack:
        return Direction.dBack
    else:
        return Direction.dNone

proc isOpposite(direction: Direction, otherDirection: Direction): bool =
    if direction == dNone:
        return false
    elif direction == dRight:
        return otherDirection == dLeft
    elif direction == dFront:
        return otherDirection == dBack
    elif direction == dLeft:
        return otherDirection == dRight
    elif direction == dBack:
        return otherDirection == dFront

proc changeVelocityOnSlope(phy: PhysicsComponent, slopeDirection: Direction) =
    if phy.velocity == 0:
        phy.velocity.inc()
        phy.direction = slopeDirection
    elif phy.direction == slopeDirection:
        phy.velocity.inc()
    elif phy.direction.isOpposite(slopeDirection):
        phy.velocity.dec()
        if phy.velocity == 0:
            phy.direction = Direction.dNone

proc standingOn(reg: Registry, pos: PositionComponent): Option[Entity] =
    for e in reg.entitiesWith(PositionComponent, WorldTileComponent):
        let tpos = reg.getComponent[:PositionComponent](e)
        if tpos.x == pos.x and tpos.y == pos.y and tpos.z == pos.z - 1:
            return some(e)
    return none(Entity)

proc moveDirection(pos: PositionComponent, direction: Direction) =
    if direction == dNone:
        return
    elif direction == dRight:
        pos.y.inc()
    elif direction == dFront:
        pos.x.inc()
    elif direction == dLeft:
        pos.y.dec()
    elif direction == dBack:
        pos.x.dec()

proc moveFromVelocity(reg: Registry, pos: PositionComponent,
        phy: PhysicsComponent) =
    if phy.velocity == 0:
        return
    let entityUnder = reg.standingOn(pos)
    if entityUnder.isNone:
        return

    let entity: Entity = entityUnder.get()
    let tileUnder: WorldTileType = reg.getComponents(entity,
                    WorldTileComponent)[0].worldTile
    if tileUnder == wttTile:
        moveDirection(pos, phy.direction)
    if tileUnder == wttSlopeRight:
        let slopeDirection: Direction = getSlopeDirection(wttSlopeRight)
        if phy.direction == slopeDirection:
            pos.y.inc()
            pos.z.dec()

proc physicsSystem*(reg: Registry) =
    for (pos, phy) in reg.entitiesWithComponents(PositionComponent,
            PhysicsComponent):
        moveFromVelocity(reg, pos, phy)
        let entityUnder = reg.standingOn(pos)
        if entityUnder.isNone():
            pos.z.dec
        else:
            let entity: Entity = entityUnder.get()
            let tileUnder: WorldTileType = reg.getComponents(entity,
                    WorldTileComponent)[0].worldTile
            if tileUnder == wttTile:
                if phy.velocity > 0:
                    phy.velocity.dec()
                    if phy.velocity == 0:
                        phy.direction = Direction.dNone
            elif tileUnder == WorldTileType.wttSlopeRight:
                changeVelocityOnSlope(phy, dRight)
                moveFromVelocity(reg, pos, phy)
