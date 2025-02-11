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

# The ratio between 
# the distance from the center of a hexagon to one of its vertices and 
# the distance from the center of a hexagon to the midpoint of one of its edges.
const HEX_EDGE_RATIO: float = sqrt(3.0) / 2.0

# The maximimum values for various character and attack stats.
const MAX_STAT: int = 1000
const MAX_MAP_DIST: int = 20

# The formatted error string for when a signal fails to connect in a state machine.
# Format [
# error code, 
# signal name,
# signal source node, 
# connecting node's parent, 
# connecting node, 
# signal method
#]
const ERROR_SIGNAL_CONNECT_FAILED: String = "ERROR CODE %d\n" + \
	"Failed to connect %s signal from %s node to %s %s node method '%s'." 

# The formatted error string for when a node's own signal fails to connect.
# Format [
# error code, 
# signal name,
# signal source node,
# signal method
#]
const ERROR_SIGNAL_CONNECT_SELF_FAILED: String = "ERROR CODE %d\n" + \
	"Failed to connect %s own %s signal to its own method '%s'."

# The path to a default icon.
const DEFAULT_ICON_PATH: String = "res://icon.png"
