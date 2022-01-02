import ../ecs/ecs

type
  WorldTileType = enum
    tile, slopeLeft, slopeRight, slopeFront, slopeBack

type
    WorldTileComponent* = ref object of Component
        worldTile*: WorldTileType