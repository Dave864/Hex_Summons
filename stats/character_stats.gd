extends Node
class_name CharacterStats
"""
Node that keeps track of all of a character's statistics.
"""


export(NodePath) var movement_node = null
export(NodePath) var health_node = null
export(NodePath) var attack_node = null
export(NodePath) var defense_node = null
export(NodePath) var agility_node = null
export(NodePath) var magic_earth_node = null
export(NodePath) var magic_fire_node = null
export(NodePath) var magic_water_node = null
export(NodePath) var magic_wind_node = null
export(NodePath) var res_earth_node = null
export(NodePath) var res_fire_node = null
export(NodePath) var res_water_node = null
export(NodePath) var res_wind_node = null


func get_movement_range() -> int:
	return movement_node.radius if movement_node != null else 0


# Get the indexes of the tiles within movement range.
func get_movement_area() -> Array:
	if movement_node != null:
		return movement_node.tile_ids
	return []


func get_max_health() -> int:
	return health_node.max_value if health_node != null else 0


func set_cur_health(val: int) -> void:
	if health_node != null:
		health_node.set_current_value(val)


func get_cur_health() -> int:
	return health_node.cur_value if health_node != null else 0


func get_attack() -> int:
	return attack_node.value if attack_node != null else 0


func get_defense() -> int:
	return defense_node.value if defense_node != null else 0


func get_agility() -> int:
	return agility_node.value if agility_node != null else 0


func get_magic(type: int) -> int:
	match type:
		Magic.Element.EARTH:
			return magic_earth_node.value if magic_earth_node != null else 0
		Magic.Element.FIRE:
			return magic_fire_node.value if magic_fire_node != null else 0
		Magic.Element.WATER:
			return magic_water_node.value if magic_water_node != null else 0
		Magic.Element.WIND:
			return magic_wind_node.value if magic_wind_node != null else 0
		_:
			return 0


func get_resistance(type: int) -> int:
	match type:
		Resistance.Element.EARTH:
			return res_earth_node.value if res_earth_node != null else 0
		Resistance.Element.FIRE:
			return res_fire_node.value if res_fire_node != null else 0
		Resistance.Element.WATER:
			return res_water_node.value if res_water_node != null else 0
		Resistance.Element.WIND:
			return res_wind_node.value if res_wind_node != null else 0
		_:
			return 0
