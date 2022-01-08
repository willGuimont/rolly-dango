import ../ecs/ecs
import ../components/positioncomponent
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
