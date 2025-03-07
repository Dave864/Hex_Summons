extends Node
class_name CharacterStats
"""
Node that keeps track of all of a character's statistics.
"""

signal health_changed(new_value)

const LEVEL: String = "Level"
const MOVEMENT: String = "Movement"
const HEALTH: String = "Health"
const ATTACK: String = "Attack"
const DEFENSE: String = "Defense"
const AGILITY: String = "Agility"
const MAGIC_E: String = "MagicEarth"
const MAGIC_F: String = "MagicFire"
const MAGIC_WT: String = "MagicWater"
const MAGIC_WD: String = "MagicWind"
const RES_E: String = "ResistanceEarth"
const RES_F: String = "ResistanceFire"
const RES_WT: String = "ResistanceWater"
const RES_WD: String = "ResistanceWind"

var _level: int = 1 setget set_level, get_level
var _movement_node: RingArea = null
var _current_health: int = 0
var _health_node: Stat = null
var _attack_node: Stat = null
var _defense_node: Stat = null
var _agility_node: Stat = null
# Magic values
var _magic_earth_node: ElementalStat = null
var _magic_fire_node: ElementalStat = null
var _magic_water_node: ElementalStat = null
var _magic_wind_node: ElementalStat = null
# Resistance values
var _res_earth_node: ElementalStat = null
var _res_fire_node: ElementalStat = null
var _res_water_node: ElementalStat = null
var _res_wind_node: ElementalStat = null


func _ready() -> void:
	# Movement, health, attack, defense, and agility are all required stats for
	# a character.
	_movement_node = get_node(MOVEMENT)
	_health_node = get_node(HEALTH)
	_attack_node = get_node(ATTACK)
	_defense_node = get_node(DEFENSE)
	_agility_node = get_node(AGILITY)
	# Magic and resistance are not strictly required for all characters.
	_magic_earth_node = get_node_or_null(MAGIC_E)
	_magic_fire_node = get_node_or_null(MAGIC_F)
	_magic_water_node = get_node_or_null(MAGIC_WT)
	_magic_wind_node = get_node_or_null(MAGIC_WD)
	_res_earth_node = get_node_or_null(RES_E)
	_res_fire_node = get_node_or_null(RES_F)
	_res_water_node = get_node_or_null(RES_WT)
	_res_wind_node = get_node_or_null(RES_WD)


func set_level(val: int) -> void:
	_level = val if val > 0 else 0


func get_level() -> int:
	return _level


func set_movement_range(val: int) -> void:
	if _movement_node != null:
		_movement_node.set_radius(val)
	else:
		ErrorUtil.missing_stat_for_node(get_parent().name, MOVEMENT)


func get_movement_range() -> int:
	var r: int
	if _movement_node != null:
		r = _movement_node.radius
	else:
		ErrorUtil.missing_stat_for_node(get_parent().name, MOVEMENT)
		r = 0
	return r


# Get the indexes of the tiles within movement range.
func get_movement_area() -> Array:
	var area: Array
	if _movement_node != null:
		area = _movement_node.tile_ids.duplicate(true)
	else:
		ErrorUtil.missing_stat_for_node(get_parent().name, MOVEMENT)
		area = []
	return area


func get_max_health() -> int:
	return _health_node.base_value + (_health_node.growth_rate * _level)


func set_cur_health(val: int) -> void:
	var mh: int = get_max_health()
	_current_health = mh if val > mh else 0 if val < 0 else val
	emit_signal("health_changed", _current_health)


func get_cur_health() -> int:
	return _current_health


func get_attack() -> int:
	return _get_stat(_attack_node, ATTACK)


func get_defense() -> int:
	return _get_stat(_defense_node, DEFENSE)


func get_agility() -> int:
	return _get_stat(_agility_node, AGILITY)


func get_magic(type: int) -> int:
	match type:
		ElementalStat.Element.EARTH:
			return _get_elemental_stat(_magic_earth_node)
		ElementalStat.Element.FIRE:
			return _get_elemental_stat(_magic_fire_node)
		ElementalStat.Element.WATER:
			return _get_elemental_stat(_magic_water_node)
		ElementalStat.Element.WIND:
			return _get_elemental_stat(_magic_wind_node)
		_:
			return 0


func get_resistance(type: int) -> int:
	match type:
		ElementalStat.Element.EARTH:
			return _get_elemental_stat(_res_earth_node)
		ElementalStat.Element.FIRE:
			return _get_elemental_stat(_res_fire_node)
		ElementalStat.Element.WATER:
			return _get_elemental_stat(_res_water_node)
		ElementalStat.Element.WIND:
			return _get_elemental_stat(_res_wind_node)
		_:
			return 0


# Get all the stats save for movement.
func get_all() -> Dictionary:
	return {
		LEVEL: _level,
		ATTACK: get_attack(),
		DEFENSE: get_defense(),
		AGILITY: get_agility(),
		"Magic": {
			ElementalStat.Element.EARTH: get_magic(ElementalStat.Element.EARTH),
			ElementalStat.Element.FIRE: get_magic(ElementalStat.Element.FIRE),
			ElementalStat.Element.WATER: get_magic(ElementalStat.Element.WATER),
			ElementalStat.Element.WIND: get_magic(ElementalStat.Element.WIND),
		},
		"Resistance": {
			ElementalStat.Element.EARTH: get_resistance(ElementalStat.Element.EARTH),
			ElementalStat.Element.FIRE: get_resistance(ElementalStat.Element.FIRE),
			ElementalStat.Element.WATER: get_resistance(ElementalStat.Element.WATER),
			ElementalStat.Element.WIND: get_resistance(ElementalStat.Element.WIND),
		}
	}


# Obtains the calculated value for a given stat.
func _get_stat(stat_node: Stat, stat_name: String) -> int:
	var v: int
	if stat_node != null:
		v = stat_node.base_value + (stat_node.growth_rate * _level)
	else:
		v = 0
		ErrorUtil.missing_stat_for_node(get_parent().name, stat_name)
	return v


func _get_elemental_stat(stat_node: ElementalStat) -> int:
	var v: int
	v = stat_node.base_value + (stat_node.growth_rate * _level) if stat_node != null else 0
	return v
