tool
class_name HexMap
extends Spatial
# Represents the battle map of an encounter


const TILES_MANAGER: String = "TilesManager"
const RANGE_FINDER: String = "RangeFinder"

export(int, 1, 30) var z_count = 3 setget set_z_count
export(int, 1, 30) var x_count = 2 setget set_x_count


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func set_z_count(value: int):
	z_count = value
	if has_node("TilesManager"):
		$TilesManager.set_z_count(value)
	if has_node("RangeFinder"):
		$RangeFinder.set_z_count(value)


func set_x_count(value: int):
	x_count = value
	if has_node("TilesManager"):
		$TilesManager.set_x_count(value)
	if has_node("RangeFinder"):
		$RangeFinder.set_x_count(value)
