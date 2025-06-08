class_name Constants
extends Object
"""
Collection of constant values and enums that are used in various scripts 
throughout the game.
"""


# The elements that define magic and resistance. LIGHT and DARK are considered
# polar elements. FIRE, EARTH, WATER, and WIND are core elements and can each
# be aligned to either of the polar elements.
enum Element {
	EARTH,
	FIRE,
	WATER,
	WIND,
	LIGHT,
	DARK,
}

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
	SPELL,
}

# The different operations that can be performed on character stats.
enum Operation {
	INCREASE,
	DECREASE,
	SET
}

# Words referring to different character stats.
const LEVEL: String = "Level"
const MOVEMENT: String = "Movement"
const MAX_HEALTH: String = "Max Health"
const CUR_HEALTH: String = "Current Health"
const ATTACK: String = "Attack"
const DEFENSE: String = "Defense"
const AGILITY: String = "Agility"
const MAGIC: String = "Magic"
const RESISTANCE: String = "Resistance"

# The path to a default icon.
const DEFAULT_ICON_PATH: String = "res://art/icon.png"

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
const MOVE_SPEED: float = 8.0

# The value to use when adjusting the weight of a hex map astar connection point
# to account for characters of the opposite faction of the current active character.
const ASTAR_ADJUSTMENT_WEIGHT = 1000.0

# Common transparency values for materials, defined by opacity.
const OPACITY_FULL: float = 1.0
const OPACITY_THREE_QUARTER: float = 0.75
const OPACITY_HALF: float = 0.5
const OPACITY_QUARTER: float = 0.25
const OPACITY_NONE: float = 0.0
