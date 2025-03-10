class_name Constants
extends Object
"""
Collection of constant values and enums that are used in various scripts 
throughout the game.
"""


# Possible occupants of a MapTile.
enum MapOccupants {
	PLAYER,
	ENEMY,
	EMPTY,
}

# What the range finder is being used for.
enum RangeTypes {
	MOVE,
	TECHNIQUE,
	SPELL
}

# The path to a default icon.
const DEFAULT_ICON_PATH: String = "res://art/icon.png"

# The ratio between 
# the distance from the center of a hexagon to one of its vertices and 
# the distance from the center of a hexagon to the midpoint of one of its edges.
const HEX_EDGE_RATIO: float = sqrt(3.0) / 2.0

# The length value of a unit of height for an encounter map hex tile.
const HEX_TILE_UNIT_HEIGHT: float = 0.5

# The "radius" of a hexagon drawn for the purposes of illustrating an action's
# area range and effect range. The radius is the distance from the center to
# a vertex of a hexagon.
const DISPLAY_HEX_RADIUS: float = 5.0

# The vertical displacement required by the selector shape in order to keep it
# on top of map tiles.
const SELECTOR_DISPLACEMENT: float = 0.125

# The maximimum values for various character and attack stats.
const MAX_STAT: int = 1000
const MAX_MAP_DIST: int = 100

# The speed at which characters move from tile to tile.
const MOVE_SPEED: float = 5.0

# The value to use when adjusting the weight of a hex map astar connection point
# to account for characters of the opposite faction of the current active character.
const ASTAR_ADJUSTMENT_WEIGHT = 1000.0

# Common transparency values for materials, defined by opacity.
const OPACITY_FULL: float = 1.0
const OPACITY_THREE_QUARTER: float = 0.75
const OPACITY_HALF: float = 0.5
const OPACITY_QUARTER: float = 0.25
const OPACITY_NONE: float = 0.0

# Defines the positions of a unit circle that correspond to the vertices of
# a hexagon.
#    0
# 5 / \ 1
#  |   |
# 4 \ / 2
#    3
const HV_0_COORD: Vector2 = Vector2(0.0, 1.0)
const HV_1_COORD: Vector2 = Vector2(HEX_EDGE_RATIO, 0.5)
const HV_2_COORD: Vector2 = Vector2(HEX_EDGE_RATIO, -0.5)
const HV_3_COORD: Vector2 = Vector2(0.0, -1.0)
const HV_4_COORD: Vector2 = Vector2(-HEX_EDGE_RATIO, -0.5)
const HV_5_COORD: Vector2 = Vector2(-HEX_EDGE_RATIO, 0.5)
