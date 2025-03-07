tool
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
# Core stat values
var _current_health: int = 0
var _health_node: Stat = null
var _attack_node: Stat = null
var _defense_node: Stat = null
var _agility_node: Stat = null
# Magic stat values
var _magic_earth_node: ElementalStat = null
var _magic_fire_node: ElementalStat = null
var _magic_water_node: ElementalStat = null
var _magic_wind_node: ElementalStat = null
# Resistance stat values
var _res_earth_node: ElementalStat = null
var _res_fire_node: ElementalStat = null
var _res_water_node: ElementalStat = null
var _res_wind_node: ElementalStat = null

# Referene to the scene tree root.
onready var _root_node: Node = get_tree().edited_scene_root


func _ready() -> void:
	_set_movement_node()
	# Core stats.
	_health_node = _set_stat_node(HEALTH)
	_attack_node = _set_stat_node(ATTACK)
	_defense_node = _set_stat_node(DEFENSE)
	_agility_node = _set_stat_node(AGILITY)
	# Magic stats.
	_magic_earth_node = _set_elemental_stat_node(MAGIC_E, ElementalStat.Element.EARTH)
	_magic_fire_node = _set_elemental_stat_node(MAGIC_F, ElementalStat.Element.FIRE)
	_magic_water_node = _set_elemental_stat_node(MAGIC_WT, ElementalStat.Element.WATER)
	_magic_wind_node = _set_elemental_stat_node(MAGIC_WD, ElementalStat.Element.WIND)
	# Resistance stats.
	_res_earth_node = _set_elemental_stat_node(RES_E, ElementalStat.Element.EARTH)
	_res_fire_node = _set_elemental_stat_node(RES_F, ElementalStat.Element.FIRE)
	_res_water_node = _set_elemental_stat_node(RES_WT, ElementalStat.Element.WATER)
	_res_wind_node = _set_elemental_stat_node(RES_WD, ElementalStat.Element.WIND)


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
	return _get_calculated_stat(_attack_node, ATTACK)


func get_defense() -> int:
	return _get_calculated_stat(_defense_node, DEFENSE)


func get_agility() -> int:
	return _get_calculated_stat(_agility_node, AGILITY)


func get_magic(type: int) -> int:
	match type:
		ElementalStat.Element.EARTH:
			return _get_calculated_elemental_stat(_magic_earth_node)
		ElementalStat.Element.FIRE:
			return _get_calculated_elemental_stat(_magic_fire_node)
		ElementalStat.Element.WATER:
			return _get_calculated_elemental_stat(_magic_water_node)
		ElementalStat.Element.WIND:
			return _get_calculated_elemental_stat(_magic_wind_node)
		_:
			return 0


func get_resistance(type: int) -> int:
	match type:
		ElementalStat.Element.EARTH:
			return _get_calculated_elemental_stat(_res_earth_node)
		ElementalStat.Element.FIRE:
			return _get_calculated_elemental_stat(_res_fire_node)
		ElementalStat.Element.WATER:
			return _get_calculated_elemental_stat(_res_water_node)
		ElementalStat.Element.WIND:
			return _get_calculated_elemental_stat(_res_wind_node)
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


# Assign the movement node or create it if not present.
func _set_movement_node() -> void:
	var move_node: RingArea = get_node_or_null(MOVEMENT)
	if move_node == null and Engine.is_editor_hint():
		var ring_area: PackedScene = load("res://range_type/RingArea.tscn")
		_movement_node = ring_area.instance()
		_movement_node.set_owner(_root_node)
		add_child(_movement_node)
	_movement_node = move_node


# Assign the specified stat node or create it if not present.
func _set_stat_node(name: String) -> Stat:
	var s_node: Stat = get_node_or_null(name)
	if s_node == null and Engine.is_editor_hint():
		s_node = Stat.new()
		s_node.name = name
		add_child(s_node)
		s_node.set_owner(_root_node)
	return s_node


# Assign the specified elemental stat node or create it if not present.
func _set_elemental_stat_node(name: String, type: int) -> ElementalStat:
	var es_node: ElementalStat = get_node_or_null(name)
	if es_node == null and Engine.is_editor_hint():
		es_node = ElementalStat.new()
		es_node.name = name
		es_node.type = type
		add_child(es_node)
		es_node.set_owner(_root_node)
	return es_node


# Obtains the calculated value for a given stat.
func _get_calculated_stat(stat_node: Stat, stat_name: String) -> int:
	var v: int
	if stat_node != null:
		v = stat_node.base_value + (stat_node.growth_rate * _level)
	else:
		v = 0
		ErrorUtil.missing_stat_for_node(get_parent().name, stat_name)
	return v


func _get_calculated_elemental_stat(stat_node: ElementalStat) -> int:
	var v: int
	v = stat_node.base_value + (stat_node.growth_rate * _level) if stat_node != null else 0
	return v
