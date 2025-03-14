tool
class_name CharacterStats
extends Node
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
const MAGIC_E: String = "Magic_Earth"
const MAGIC_F: String = "Magic_Fire"
const MAGIC_WT: String = "Magic_Water"
const MAGIC_WD: String = "Magic_Wind"
const RES_E: String = "Res_Earth"
const RES_F: String = "Res_Fire"
const RES_WT: String = "Res_Water"
const RES_WD: String = "Res_Wind"

var _level: int = 1 setget set_level, get_level
var _current_health: int = 0

export var movement_area: Resource = null
# Core stat values
export var health: Resource = null
export var attack: Resource = null
export var defense: Resource = null
export var agility: Resource = null
# Magic stat values
export var magic_earth: Resource = null
export var magic_fire: Resource = null
export var magic_water: Resource = null
export var magic_wind: Resource = null
# Resistance stat values
export var res_earth: Resource = null
export var res_fire: Resource = null
export var res_water: Resource = null
export var res_wind: Resource = null

# Referene to the scene tree root.
onready var _root_node: Node = get_tree().edited_scene_root


func _ready() -> void:
	_set_movement_node()
	# Core stats.
	health = _set_stat_node(health, HEALTH)
	attack = _set_stat_node(attack, ATTACK)
	defense = _set_stat_node(defense, DEFENSE)
	agility = _set_stat_node(agility, AGILITY)
	# Magic stats.
	magic_earth = _set_elemental_stat_node(magic_earth, MAGIC_E, ElementalStat.Element.EARTH)
	magic_fire = _set_elemental_stat_node(magic_fire, MAGIC_F, ElementalStat.Element.FIRE)
	magic_water = _set_elemental_stat_node(magic_water, MAGIC_WT, ElementalStat.Element.WATER)
	magic_wind = _set_elemental_stat_node(magic_wind, MAGIC_WD, ElementalStat.Element.WIND)
	# Resistance stats.
	res_earth = _set_elemental_stat_node(res_earth, RES_E, ElementalStat.Element.EARTH)
	res_fire = _set_elemental_stat_node(res_fire, RES_F, ElementalStat.Element.FIRE)
	res_water = _set_elemental_stat_node(res_water,RES_WT, ElementalStat.Element.WATER)
	res_wind = _set_elemental_stat_node(res_wind, RES_WD, ElementalStat.Element.WIND)


func set_level(val: int) -> void:
	_level = val if val > 0 else 0


func get_level() -> int:
	return _level


func set_movement_range(val: int) -> void:
	if movement_area != null:
		movement_area.radius = val
	else:
		ErrorUtil.missing_stat_for_node(get_parent().name, MOVEMENT)


func get_movement_range() -> int:
	var r: int
	if movement_area != null:
		r = movement_area.radius
	else:
		ErrorUtil.missing_stat_for_node(get_parent().name, MOVEMENT)
		r = 0
	return r


# Get the indexes of the tiles within movement range.
func get_movement_area() -> Resource:
	return movement_area


func get_max_health() -> int:
	return health.base_value + (health.growth_rate * _level)


func set_cur_health(val: int) -> void:
	var mh: int = get_max_health()
	_current_health = mh if val > mh else 0 if val < 0 else val
	emit_signal("health_changed", _current_health)


# Set current health to the maximum value.
func max_cur_health() -> void:
	_current_health = get_max_health()


func get_cur_health() -> int:
	return _current_health


func get_attack() -> int:
	return _get_calculated_stat(attack, ATTACK)


func get_defense() -> int:
	return _get_calculated_stat(defense, DEFENSE)


func get_agility() -> int:
	return _get_calculated_stat(agility, AGILITY)


func get_magic(type: int) -> int:
	match type:
		ElementalStat.Element.EARTH:
			return _get_calculated_elemental_stat(magic_earth)
		ElementalStat.Element.FIRE:
			return _get_calculated_elemental_stat(magic_fire)
		ElementalStat.Element.WATER:
			return _get_calculated_elemental_stat(magic_water)
		ElementalStat.Element.WIND:
			return _get_calculated_elemental_stat(magic_wind)
		_:
			return 0


func get_resistance(type: int) -> int:
	match type:
		ElementalStat.Element.EARTH:
			return _get_calculated_elemental_stat(res_earth)
		ElementalStat.Element.FIRE:
			return _get_calculated_elemental_stat(res_fire)
		ElementalStat.Element.WATER:
			return _get_calculated_elemental_stat(res_water)
		ElementalStat.Element.WIND:
			return _get_calculated_elemental_stat(res_wind)
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
	if movement_area == null and Engine.is_editor_hint():
		movement_area = load("res://range_type/ring_area.tres").duplicate()


# Assign the specified stat node or create it if not present.
func _set_stat_node(stat: Resource, name: String) -> Resource:
	var s: Resource
	if stat == null and Engine.is_editor_hint():
		s = load("res://stats/%s.tres" % [name.to_lower()]).duplicate()
	else:
		s = stat
	return s


# Assign the specified elemental stat node or create it if not present.
func _set_elemental_stat_node(e_stat: Resource, name: String, type: int) -> Resource:
	var es: Resource
	if e_stat == null and Engine.is_editor_hint():
		es = load("res://stats/%s.tres" % [name.to_lower()]).duplicate()
		es.type = type
	else:
		es = e_stat
	return es


# Obtains the calculated value for a given stat.
func _get_calculated_stat(stat: Resource, name: String) -> int:
	var v: int
	if stat != null:
		v = stat.base_value + (stat.growth_rate * _level)
	else:
		v = 0
		ErrorUtil.missing_stat_for_node(get_parent().name, name)
	return v


func _get_calculated_elemental_stat(e_stat: Resource) -> int:
	var v: int
	v = e_stat.base_value + (e_stat.growth_rate * _level) if e_stat != null else 0
	return v
