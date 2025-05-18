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
const MAGIC: String = "Magic"
const RESISTANCE: String = "Resistance"

# Stat values
export var stat_values: Resource = null
# Reference to the movement area
export var movement_area: Resource = null

# Modifier values for all stats
var _health_mod: int = 0
var _attack_mod: int = 0
var _defense_mod: int = 0
var _agility_mod: int = 0
var _movement_mod: int = 0
var _magic_earth_mod: int = 0
var _magic_fire_mod: int = 0
var _magic_water_mod: int = 0
var _magic_wind_mod: int = 0
var _res_earth_mod: int = 0
var _res_fire_mod: int = 0
var _res_water_mod: int = 0
var _res_wind_mod: int = 0
var _level: int = 1 setget set_level, get_level
var _current_health: int = 0

# Referene to the scene tree root.
onready var _root_node: Node = get_tree().edited_scene_root


func _ready() -> void:
	_check_for_required_parameters()
	movement_area.radius = stat_values.movement


func set_level(val: int) -> void:
	_level = val if val > 0 else 0


func get_level() -> int:
	return _level


func set_movement_range(val: int) -> void:
	movement_area.radius = val
	stat_values.movement = val


func get_movement_range() -> int:
	return _get_calculated_stat(Stat.Type.MOVEMENT)


# Get the indexes of the tiles within movement range.
func get_movement_area() -> Resource:
	return movement_area


func get_max_health() -> int:
	return _get_calculated_stat(Stat.Type.HEALTH)


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
	return _get_calculated_stat(Stat.Type.ATTACK)


func get_defense() -> int:
	return _get_calculated_stat(Stat.Type.DEFENSE)


func get_agility() -> int:
	return _get_calculated_stat(Stat.Type.AGILITY)


func get_magic(type: int) -> int:
	return _get_calculated_elemental_stat(ElementalStat.Type.MAGIC, type)


func get_resistance(type: int) -> int:
	return _get_calculated_elemental_stat(ElementalStat.Stat.RESISTANCE, type)


# Get all the stats.
func get_all() -> Dictionary:
	return {
		LEVEL: _level,
		HEALTH: get_max_health(),
		ATTACK: get_attack(),
		DEFENSE: get_defense(),
		AGILITY: get_agility(),
		MOVEMENT: get_movement_range(),
		MAGIC: {
			ElementalStat.Element.EARTH: get_magic(ElementalStat.Element.EARTH),
			ElementalStat.Element.FIRE: get_magic(ElementalStat.Element.FIRE),
			ElementalStat.Element.WATER: get_magic(ElementalStat.Element.WATER),
			ElementalStat.Element.WIND: get_magic(ElementalStat.Element.WIND),
		},
		RESISTANCE: {
			ElementalStat.Element.EARTH: get_resistance(ElementalStat.Element.EARTH),
			ElementalStat.Element.FIRE: get_resistance(ElementalStat.Element.FIRE),
			ElementalStat.Element.WATER: get_resistance(ElementalStat.Element.WATER),
			ElementalStat.Element.WIND: get_resistance(ElementalStat.Element.WIND),
		}
	}


# Updates the modifier for the specified stat.
func update_modifier(type: int, value: int) -> void:
	match type:
		Stat.Type.HEALTH:
			_health_mod += value
		Stat.Type.ATTACK:
			_attack_mod += value
		Stat.Type.DEFENSE:
			_defense_mod += value
		Stat.Type.AGILITY:
			_agility_mod += value
		Stat.Type.MOVEMENT:
			_movement_mod += value


# Updates the modifier for the specified elemental stat.
func update_elemental_modifier(type: int, element: int, value: int) -> void:
	match element:
		ElementalStat.Element.EARTH:
			if type == ElementalStat.Type.MAGIC:
				_magic_earth_mod += value
			elif type == ElementalStat.Type.RESISTANCE:
				_res_earth_mod += value
		ElementalStat.Element.FIRE:
			if type == ElementalStat.Type.MAGIC:
				_magic_fire_mod += value
			elif type == ElementalStat.Type.RESISTANCE:
				_res_fire_mod += value
		ElementalStat.Element.WATER:
			if type == ElementalStat.Type.MAGIC:
				_magic_water_mod += value
			elif type == ElementalStat.Type.RESISTANCE:
				_res_water_mod += value
		ElementalStat.Element.WIND:
			if type == ElementalStat.Type.MAGIC:
				_magic_wind_mod += value
			elif type == ElementalStat.Type.RESISTANCE:
				_res_wind_mod += value


# Obtains the calculated value for a given stat.
func _get_calculated_stat(stat: int) -> int:
	match stat:
		Stat.Type.HEALTH:
			return (
					(
						stat_values.health_base
						+ stat_values.health_growth
						* _level
					)
					+ _health_mod
			)
		Stat.Type.ATTACK:
			return (
					(
						stat_values.attack_base
						+ stat_values.attack_growth
						* _level
					)
					+ _attack_mod
			)
		Stat.Type.DEFENSE:
			return (
					(
						stat_values.defense_base
						+ stat_values.defense_growth
						* _level
					)
					+ _defense_mod
			)
		Stat.Type.AGILITY:
			return (
					(
						stat_values.agility_base
						+ stat_values.agility_growth
						* _level
					)
					+ _agility_mod
			)
		Stat.Type.MOVEMENT:
			return stat_values.movement + _movement_mod
		_:
			return 0


# Obtains the calculated value for a given elemental stat.
func _get_calculated_elemental_stat(stat: int, element: int) -> int:
	match stat:
		ElementalStat.Type.MAGIC:
			return _magic_for_level(element)
		ElementalStat.Type.RESISTANCE:
			return _resistance_for_level(element)
		_:
			return 0


# Determines the value of a specified magic element for a given level.
func _magic_for_level(element: int) -> int:
	match element:
		ElementalStat.Element.EARTH:
			return (
					(
						stat_values.magic_earth_base
						+ stat_values.magic_earth_growth
						* _level
					)
					+ _magic_earth_mod
			)
		ElementalStat.Element.FIRE:
			return (
					(
						stat_values.magic_fire_base
						+ stat_values.magic_fire_growth
						* _level
					)
					+ _magic_fire_mod
			)
		ElementalStat.Element.WATER:
			return (
					(
						stat_values.magic_water_base
						+ stat_values.magic_water_growth
						* _level
					)
					+ _magic_water_mod
			)
		ElementalStat.Element.WIND:
			return (
					(
						stat_values.magic_wind_base
						+ stat_values.magic_wind_growth
						* _level
					)
					+ _magic_wind_mod
			)
		_:
			return 0


# Determines the value of a specified resistance element for a given level.
func _resistance_for_level(element: int) -> int:
	match element:
		ElementalStat.Element.EARTH:
			return (
					(
						stat_values.res_earth_base
						+ stat_values.res_earth_growth
						* _level
					)
					+ _res_earth_mod
			)
		ElementalStat.Element.FIRE:
			return (
					(
						stat_values.res_fire_base
						+ stat_values.res_fire_growth
						* _level
					)
					+ _res_fire_mod
			)
		ElementalStat.Element.WATER:
			return (
					(
						stat_values.res_water_base
						+ stat_values.res_water_growth
						* _level
					)
					+ _res_water_mod
			)
		ElementalStat.Element.WIND:
			return (
					(
						stat_values.res_wind_base
						+ stat_values.res_wind_growth
						* _level
					)
					+ _res_wind_mod
			)
		_:
			return 0


# Check that all required parameters are set.
func _check_for_required_parameters() -> void:
	assert(
			movement_area != null,
			ErrorUtil.missing_required_parameter(self.name, "movement_area")
	)
	assert(
			movement_area is RingArea,
			"Error: CharacterStat movement_area is not of type RingArea."
	)
	assert(
			stat_values != null,
			ErrorUtil.missing_required_parameter(self.name, "stat_values")
	)
	assert(
			stat_values is StatValues,
			"Error: CharacterStat stat_values is not of type CoreStats. "
	)
