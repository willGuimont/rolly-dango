import statemachine
import ../ecs/ecs
import ../components/worldtilecomponent

type
    LevelState* = ref object of BaseState
        reg*: Registry
        levelData*: Level[array[500, uint8]]
        wasBuilt*: bool

method execute*(s: LevelState) = 
    if not s.wasBuilt:
        s.reg.buildLevel(s.levelData)
