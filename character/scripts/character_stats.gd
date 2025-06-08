tool
class_name CharacterStats
extends Node
"""
Node that keeps track of all of a character's statistics.
"""


signal health_changed(new_value)

# Stat values
export var base_stat_values: Resource = null

# Modifier values for all stats
var _max_health_mod: int = 0
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


func set_level(val: int) -> void:
	_level = val if val > 0 else 0


func get_level() -> int:
	return _level


func set_movement_range(val: int) -> void:
	base_stat_values.movement = val


func get_movement_range(with_modifier: bool = true) -> int:
	return get_stat(Stat.Type.MOVEMENT, with_modifier)


func get_max_health(with_modifier: bool = true) -> int:
	return get_stat(Stat.Type.MAX_HEALTH, with_modifier)


func set_cur_health(val: int) -> void:
	var mh: int = get_max_health()
	_current_health = mh if val > mh else 0 if val < 0 else val
	emit_signal("health_changed", _current_health)


# Set current health to the maximum value.
func max_cur_health() -> void:
	_current_health = get_max_health()


func get_cur_health() -> int:
	return get_stat(Stat.Type.CUR_HEALTH)


func get_attack(with_modifier: bool = true) -> int:
	return get_stat(Stat.Type.ATTACK, with_modifier)


func get_defense(with_modifier: bool = true) -> int:
	return get_stat(Stat.Type.DEFENSE, with_modifier)


func get_agility(with_modifier: bool = true) -> int:
	return get_stat(Stat.Type.AGILITY, with_modifier)


func get_magic(element: int, with_modifier: bool = true) -> int:
	return _magic_for_level(element, with_modifier)


func get_resistance(element: int, with_modifier: bool = true) -> int:
	return _resistance_for_level(element, with_modifier)


# Get all the stats.
func get_all(with_modifier: bool = true) -> Dictionary:
	var all_stats: Dictionary = {
		Constants.LEVEL: _level,
		Constants.MAX_HEALTH: get_max_health(with_modifier),
		Constants.CUR_HEALTH: get_max_health(with_modifier),
		Constants.AGILITY: get_agility(with_modifier),
		Constants.MOVEMENT: get_movement_range(with_modifier),
	}
	all_stats.merge(get_offensive(with_modifier))
	all_stats.merge(get_defensive(with_modifier))
	return all_stats


# Get the offensive stats.
func get_offensive(with_modifier: bool = true) -> Dictionary:
	return {
		Constants.ATTACK: get_attack(with_modifier),
		Constants.MAGIC: {
			Constants.Element.EARTH: get_magic(
					Constants.Element.EARTH,
					with_modifier
			),
			Constants.Element.FIRE: get_magic(
					Constants.Element.FIRE,
					with_modifier
			),
			Constants.Element.WATER: get_magic(
					Constants.Element.WATER,
					with_modifier
			),
			Constants.Element.WIND: get_magic(
					Constants.Element.WIND,
					with_modifier
			),
			Constants.Element.LIGHT: get_magic(
					Constants.Element.LIGHT,
					with_modifier
			),
			Constants.Element.DARK: get_magic(
					Constants.Element.DARK,
					with_modifier
			),
		}
	}


# Get the defensive stats.
func get_defensive(with_modifier: bool = true) -> Dictionary:
	return {
		Constants.DEFENSE: get_defense(),
		Constants.RESISTANCE: {
			Constants.Element.EARTH: get_resistance(
					Constants.Element.EARTH,
					with_modifier
			),
			Constants.Element.FIRE: get_resistance(
					Constants.Element.FIRE,
					with_modifier
			),
			Constants.Element.WATER: get_resistance(
					Constants.Element.WATER,
					with_modifier
			),
			Constants.Element.WIND: get_resistance(
					Constants.Element.WIND,
					with_modifier
			),
			Constants.Element.LIGHT: get_resistance(
					Constants.Element.LIGHT,
					with_modifier
			),
			Constants.Element.DARK: get_resistance(
					Constants.Element.DARK,
					with_modifier
			),
		}
	}


# Obtains the value for a given stat.
func get_stat(stat: int, with_modifier: bool = true) -> int:
	var result: int
	var modifier: int
	match stat:
		Stat.Type.MAX_HEALTH:
			result = base_stat_values.health_base + (base_stat_values.health_growth * _level)
			modifier = _max_health_mod
		Stat.Type.CUR_HEALTH:
			result = _current_health
			modifier = 0
		Stat.Type.ATTACK:
			result = base_stat_values.attack_base + (base_stat_values.attack_growth * _level)
			modifier = _attack_mod
		Stat.Type.DEFENSE:
			result = base_stat_values.defense_base + (base_stat_values.defense_growth * _level)
			modifier = _defense_mod
		Stat.Type.AGILITY:
			result = base_stat_values.agility_base + (base_stat_values.agility_growth * _level)
			modifier = _agility_mod
		Stat.Type.MOVEMENT:
			result = base_stat_values.movement
			modifier = _movement_mod
		_:
			result = 0
			modifier = 0
	return result + modifier if with_modifier else result


# Updates the modifier for the specified stat so that it results in the new value
# when added to the base value of the stat.
func update_modifier(type: int, value: int) -> void:
	match type:
		Stat.Type.MAX_HEALTH:
			_max_health_mod = value
		Stat.Type.ATTACK:
			_attack_mod = value
		Stat.Type.DEFENSE:
			_defense_mod = value
		Stat.Type.AGILITY:
			_agility_mod = value
		Stat.Type.MOVEMENT:
			_movement_mod = value


# Updates the modifier for the specified elemental magic stat so that it
# results in the new value when added to the base value of the stat.
func update_magic_modifier(element: int, value: int) -> void:
	match element:
		Constants.Element.EARTH:
			_magic_earth_mod = value
		Constants.Element.FIRE:
			_magic_fire_mod = value
		Constants.Element.WATER:
			_magic_water_mod = value
		Constants.Element.WIND:
			_magic_wind_mod = value
		Constants.Element.LIGHT:
			var light_elements: Array = ElementalPolarity.get_light_elements()
			update_magic_modifier(light_elements[0], value)
			update_magic_modifier(light_elements[1], value)
		Constants.Element.DARK:
			var dark_elements: Array = ElementalPolarity.get_dark_elements()
			update_magic_modifier(dark_elements[0], value)
			update_magic_modifier(dark_elements[1], value)


# Updates the modifier for the specified elemental resistance stat so that it
# results in the new value when added to the base value of the stat.
func update_res_modifier(element: int, value: int) -> void:
	match element:
		Constants.Element.EARTH:
			_res_earth_mod = value
		Constants.Element.FIRE:
			_res_fire_mod = value
		Constants.Element.WATER:
			_res_water_mod = value
		Constants.Element.WIND:
			_res_wind_mod = value
		Constants.Element.LIGHT:
			var light_elements: Array = ElementalPolarity.get_light_elements()
			update_res_modifier(light_elements[0], value)
			update_res_modifier(light_elements[1], value)
		Constants.Element.DARK:
			var dark_elements: Array = ElementalPolarity.get_dark_elements()
			update_res_modifier(dark_elements[0], value)
			update_res_modifier(dark_elements[1], value)


# sets the values of all the modifiers to zero. Used when effects are processed.
func clear_modifiers() -> void:
	update_modifier(Stat.Type.MAX_HEALTH, 0)
	update_modifier(Stat.Type.ATTACK, 0)
	update_modifier(Stat.Type.DEFENSE, 0)
	update_modifier(Stat.Type.AGILITY, 0)
	update_modifier(Stat.Type.MOVEMENT, 0)
	for element in Constants.Element:
		update_magic_modifier(element, 0)
		update_res_modifier(element, 0)


# Determines the value of a specified magic element for a given level.
func _magic_for_level(element: int, with_modifier: bool) -> int:
	var result: int
	var modifier: int
	match element:
		Constants.Element.EARTH:
			result = (
					base_stat_values.magic_earth_base 
					+ (base_stat_values.magic_earth_growth * _level)
			)
			modifier = _magic_earth_mod
		Constants.Element.FIRE:
			result = (
					base_stat_values.magic_fire_base
					+ (base_stat_values.magic_fire_growth * _level)
			)
			modifier = _magic_fire_mod
		Constants.Element.WATER:
			result = (
					base_stat_values.magic_water_base
					+ (base_stat_values.magic_water_growth * _level)
			)
			modifier = _magic_water_mod
		Constants.Element.WIND:
			result = (
					base_stat_values.magic_wind_base
					+ (base_stat_values.magic_wind_growth * _level)
			)
			modifier = _magic_wind_mod
		Constants.Element.LIGHT:
			var light_elements: Array = ElementalPolarity.get_light_elements()
			return (
				_magic_for_level(light_elements[0], with_modifier)
				+ _magic_for_level(light_elements[1], with_modifier)
			)
		Constants.Element.DARK:
			var dark_elements: Array = ElementalPolarity.get_dark_elements()
			return (
				_magic_for_level(dark_elements[0], with_modifier)
				+ _magic_for_level(dark_elements[1], with_modifier)
			)
		_:
			result = 0
			modifier = 0
	return result + modifier if with_modifier else result


# Determines the value of a specified resistance element for a given level.
func _resistance_for_level(element: int, with_modifier: bool) -> int:
	var result: int
	var modifier: int
	match element:
		Constants.Element.EARTH:
			result = (
					base_stat_values.res_earth_base 
					+ (base_stat_values.res_earth_growth * _level)
			)
			modifier = _res_earth_mod
		Constants.Element.FIRE:
			result = (
					base_stat_values.res_fire_base 
					+ (base_stat_values.res_fire_growth * _level)
			)
			modifier = _res_fire_mod
		Constants.Element.WATER:
			result = (
					base_stat_values.res_water_base 
					+ (base_stat_values.res_water_growth * _level)
			)
			modifier = _res_water_mod
		Constants.Element.WIND:
			result = (
					base_stat_values.res_wind_base 
					+ (base_stat_values.res_wind_growth * _level)
			)
			modifier = _res_wind_mod
		Constants.Element.LIGHT:
			var light_elements: Array = ElementalPolarity.get_light_elements()
			return (
				_resistance_for_level(light_elements[0], with_modifier)
				+ _resistance_for_level(light_elements[1], with_modifier)
			)
		Constants.Element.DARK:
			var dark_elements: Array = ElementalPolarity.get_dark_elements()
			return (
				_resistance_for_level(dark_elements[0], with_modifier)
				+ _resistance_for_level(dark_elements[1], with_modifier)
			)
		_:
			result = 0
			modifier = 0
	return result + modifier if with_modifier else result


# Check that all required parameters are set.
func _check_for_required_parameters() -> void:
	assert(
			base_stat_values != null,
			ErrorUtil.missing_required_parameter(self.name, "base_stat_values")
	)
	assert(
			base_stat_values is BaseStats,
			"Error: CharacterStat base_stat_values is not of type BaseStats."
	)
