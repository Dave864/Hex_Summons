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
const HEX_TILE_UNIT_HEIGHT: float = 0.25

# The "radius" of a hexagon drawn for the purposes of illustrating an action's
# area range and effect range. The radius is the distance from the center to
# a vertex of a hexagon
const DISPLAY_HEX_RADIUS: float = 5.0

# The maximimum values for various character and attack stats.
const MAX_STAT: int = 1000
const MAX_MAP_DIST: int = 100

# The value to use when adjusting the weight of a hex map astar connection point
# to account for characters of the opposite faction of the current active character.
const ASTAR_ADJUSTMENT_WEIGHT = 1000.0

# A collection of colors set for various indicators.
const COLOR_AREA_RANGE: Color = Color.blue
const COLOR_CHARACTER_ORIGIN: Color = Color.dodgerblue
const COLOR_ALLY_ORIGIN: Color = Color.aqua
const COLOR_EFFECT_RANGE: Color = Color.yellow
const COLOR_EFFECT_ORIGIN: Color = Color.orangered
const COLOR_TARGET_SELECT: Color = Color.red

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
