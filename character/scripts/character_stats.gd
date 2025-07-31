tool
class_name CharacterStats
extends Node
"""
Node that keeps track of all of a character's statistics.
"""


signal health_changed(new_value, old_value)
signal agility_changed(new_value)

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


func set_level(val: int) -> void:
	_level = val if val > 0 else 0


func get_level() -> int:
	return _level


func get_movement_range(with_modifier: bool = true) -> int:
	return get_stat(Stat.Type.MOVEMENT, with_modifier)


# Updates the current health by the given delta.
func set_cur_health(delta: int) -> void:
	var val: int = get_stat(Stat.Type.CUR_HEALTH) + delta
	var mh: int = get_stat(Stat.Type.MAX_HEALTH)
	val = int(clamp(val, 0, mh))
	emit_signal("health_changed", val, mh)
	_current_health = val


# Set current health to the maximum value.
func max_cur_health() -> void:
	_current_health = get_stat(Stat.Type.MAX_HEALTH)


# Get all the stats.
func get_all(with_modifier: bool = true) -> Dictionary:
	var all_stats: Dictionary = {
		Constants.LEVEL: _level,
		Constants.MAX_HEALTH: get_stat(Stat.Type.MAX_HEALTH, with_modifier),
		Constants.CUR_HEALTH: get_stat(Stat.Type.CUR_HEALTH, with_modifier),
		Constants.AGILITY: get_stat(Stat.Type.AGILITY, with_modifier),
		Constants.MOVEMENT: get_stat(Stat.Type.MOVEMENT, with_modifier),
	}
	all_stats.merge(get_offensive(with_modifier))
	all_stats.merge(get_defensive(with_modifier))
	return all_stats


# Get the offensive stats.
func get_offensive(with_modifier: bool = true) -> Dictionary:
	return {
		Constants.ATTACK: get_stat(Stat.Type.ATTACK, with_modifier),
		Constants.MAGIC: {
			Constants.Element.EARTH: _magic_for_level(
					Constants.Element.EARTH,
					with_modifier
			),
			Constants.Element.FIRE: _magic_for_level(
					Constants.Element.FIRE,
					with_modifier
			),
			Constants.Element.WATER: _magic_for_level(
					Constants.Element.WATER,
					with_modifier
			),
			Constants.Element.WIND: _magic_for_level(
					Constants.Element.WIND,
					with_modifier
			),
			Constants.Element.LIGHT: _magic_for_level(
					Constants.Element.LIGHT,
					with_modifier
			),
			Constants.Element.DARK: _magic_for_level(
					Constants.Element.DARK,
					with_modifier
			),
		}
	}


# Get the defensive stats.
func get_defensive(with_modifier: bool = true) -> Dictionary:
	return {
		Constants.DEFENSE: get_stat(Stat.Type.DEFENSE, with_modifier),
		Constants.RESISTANCE: {
			Constants.Element.EARTH: _resistance_for_level(
					Constants.Element.EARTH,
					with_modifier
			),
			Constants.Element.FIRE: _resistance_for_level(
					Constants.Element.FIRE,
					with_modifier
			),
			Constants.Element.WATER: _resistance_for_level(
					Constants.Element.WATER,
					with_modifier
			),
			Constants.Element.WIND: _resistance_for_level(
					Constants.Element.WIND,
					with_modifier
			),
			Constants.Element.LIGHT: _resistance_for_level(
					Constants.Element.LIGHT,
					with_modifier
			),
			Constants.Element.DARK: _resistance_for_level(
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
			result = (
					base_stat_values.health_base
					+ (base_stat_values.health_growth * _level)
			)
			modifier = _max_health_mod
		Stat.Type.CUR_HEALTH:
			result = _current_health
			modifier = 0
		Stat.Type.ATTACK:
			result = (
					base_stat_values.attack_base
					+ (base_stat_values.attack_growth * _level)
			)
			modifier = _attack_mod
		Stat.Type.DEFENSE:
			result = (
					base_stat_values.defense_base
					+ (base_stat_values.defense_growth * _level)
			)
			modifier = _defense_mod
		Stat.Type.AGILITY:
			result = (
					base_stat_values.agility_base
					+ (base_stat_values.agility_growth * _level)
			)
			modifier = _agility_mod
		Stat.Type.MOVEMENT:
			result = base_stat_values.movement
			modifier = _movement_mod
		Stat.Type.MAGIC_EARTH:
			return _magic_for_level(Constants.Element.EARTH, with_modifier)
		Stat.Type.MAGIC_FIRE:
			return _magic_for_level(Constants.Element.FIRE, with_modifier)
		Stat.Type.MAGIC_WATER:
			return _magic_for_level(Constants.Element.WATER, with_modifier)
		Stat.Type.MAGIC_WIND:
			return _magic_for_level(Constants.Element.WIND, with_modifier)
		Stat.Type.MAGIC_LIGHT:
			return _magic_for_level(Constants.Element.LIGHT, with_modifier)
		Stat.Type.MAGIC_DARK:
			return _magic_for_level(Constants.Element.DARK, with_modifier)
		Stat.Type.RES_EARTH:
			return _resistance_for_level(Constants.Element.EARTH, with_modifier)
		Stat.Type.RES_FIRE:
			return _resistance_for_level(Constants.Element.FIRE, with_modifier)
		Stat.Type.RES_WATER:
			return _resistance_for_level(Constants.Element.WATER, with_modifier)
		Stat.Type.RES_WIND:
			return _resistance_for_level(Constants.Element.WIND, with_modifier)
		Stat.Type.RES_LIGHT:
			return _resistance_for_level(Constants.Element.LIGHT, with_modifier)
		Stat.Type.RES_DARK:
			return _resistance_for_level(Constants.Element.DARK, with_modifier)
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
			var change_vale: int = _agility_mod - value
			_agility_mod = value
			if change_vale != 0:
				emit_signal("agility_changed", get_stat(Stat.Type.AGILITY))
		Stat.Type.MOVEMENT:
			_movement_mod = value
		Stat.Type.MAGIC_EARTH:
			_update_magic_modifier(Constants.Element.EARTH, value)
		Stat.Type.MAGIC_FIRE:
			_update_magic_modifier(Constants.Element.FIRE, value)
		Stat.Type.MAGIC_WATER:
			_update_magic_modifier(Constants.Element.WATER, value)
		Stat.Type.MAGIC_WIND:
			_update_magic_modifier(Constants.Element.WIND, value)
		Stat.Type.MAGIC_LIGHT:
			_update_magic_modifier(Constants.Element.LIGHT, value)
		Stat.Type.MAGIC_DARK:
			_update_magic_modifier(Constants.Element.DARK, value)
		Stat.Type.RES_EARTH:
			_update_res_modifier(Constants.Element.EARTH, value)
		Stat.Type.RES_FIRE:
			_update_res_modifier(Constants.Element.FIRE, value)
		Stat.Type.RES_WATER:
			_update_res_modifier(Constants.Element.WATER, value)
		Stat.Type.RES_WIND:
			_update_res_modifier(Constants.Element.WIND, value)
		Stat.Type.RES_LIGHT:
			_update_res_modifier(Constants.Element.LIGHT, value)
		Stat.Type.RES_DARK:
			_update_res_modifier(Constants.Element.DARK, value)


# sets the values of all the modifiers to zero. Used when effects are processed.
func clear_modifiers() -> void:
	update_modifier(Stat.Type.MAX_HEALTH, 0)
	update_modifier(Stat.Type.ATTACK, 0)
	update_modifier(Stat.Type.DEFENSE, 0)
	update_modifier(Stat.Type.AGILITY, 0)
	update_modifier(Stat.Type.MOVEMENT, 0)
	for element in Constants.Element:
		_update_magic_modifier(element, 0)
		_update_res_modifier(element, 0)


func _ready() -> void:
	_check_for_required_parameters()
	"""
	TODO: Eventually set up way to preserve current player health across
	encounters and set enemy health to max (or relevant value) at encounter
	start.
	"""
	max_cur_health()


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


# Updates the modifier for the specified elemental magic stat so that it
# results in the new value when added to the base value of the stat.
func _update_magic_modifier(element: int, value: int) -> void:
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
			_update_magic_modifier(light_elements[0], value)
			_update_magic_modifier(light_elements[1], value)
		Constants.Element.DARK:
			var dark_elements: Array = ElementalPolarity.get_dark_elements()
			_update_magic_modifier(dark_elements[0], value)
			_update_magic_modifier(dark_elements[1], value)


# Updates the modifier for the specified elemental resistance stat so that it
# results in the new value when added to the base value of the stat.
func _update_res_modifier(element: int, value: int) -> void:
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
			_update_res_modifier(light_elements[0], value)
			_update_res_modifier(light_elements[1], value)
		Constants.Element.DARK:
			var dark_elements: Array = ElementalPolarity.get_dark_elements()
			_update_res_modifier(dark_elements[0], value)
			_update_res_modifier(dark_elements[1], value)


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
