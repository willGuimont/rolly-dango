import ../ecs/ecs

type
  WorldTileType = enum
    wttTile, wttSlopeLeft, wttSlopeRight, wttSlopeFront, wttSlopeBack

type
    WorldTileComponent* = ref object of Component
        worldTile*: WorldTileType
