import ../ecs/ecs
import ../components/positioncomponent
import ../components/worldtilecomponent
import ../events/eventqueue
import ../state/levelstateevents

type
    PlayerComponent* = ref object of Component
        gameTopic*: GameTopic

proc playerUpdate*(reg: Registry) =
    for (pos, player) in reg.entitiesWithComponents(PositionComponent,
            PlayerComponent):
        if pos.z <= -5:
            player.gameTopic.sendMessage(gmReset)
        for (tpos, t) in reg.entitiesWithComponents(PositionComponent,
                WorldTileComponent):
            if t.tileType == wttEnding and pos.x == tpos.x and pos.y ==
                    tpos.y and pos.z == tpos.z:
                player.gameTopic.sendMessage(gmNextLevel)
