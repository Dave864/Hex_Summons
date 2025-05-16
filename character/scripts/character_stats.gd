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

var _level: int = 1 setget set_level, get_level
var _current_health: int = 0

# Core stat values
export var core_stats: Resource = null
# Elemental stat values
export var elemental_stats: Resource = null
# Reference to the movement area
export var movement_area: Resource = null

# Referene to the scene tree root.
onready var _root_node: Node = get_tree().edited_scene_root


func _ready() -> void:
	_check_for_required_parameters()
	movement_area.radius = core_stats.movement


func set_level(val: int) -> void:
	_level = val if val > 0 else 0


func get_level() -> int:
	return _level


func set_movement_range(val: int) -> void:
	movement_area.radius = val
	core_stats.movement = val


func get_movement_range() -> int:
	return _get_calculated_stat(CoreStats.Type.MOVEMENT)


# Get the indexes of the tiles within movement range.
func get_movement_area() -> Resource:
	return movement_area


func get_max_health() -> int:
	return _get_calculated_stat(CoreStats.Type.HEALTH)


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
	return _get_calculated_stat(CoreStats.Type.ATTACK)


func get_defense() -> int:
	return _get_calculated_stat(CoreStats.Type.DEFENSE)


func get_agility() -> int:
	return _get_calculated_stat(CoreStats.Type.AGILITY)


func get_magic(type: int) -> int:
	return _get_calculated_elemental_stat(ElementalStats.Type.MAGIC, type)


func get_resistance(type: int) -> int:
	return _get_calculated_elemental_stat(ElementalStats.Stat.RESISTANCE, type)


# Get all the stats save for movement.
func get_all() -> Dictionary:
	return {
		LEVEL: _level,
		ATTACK: get_attack(),
		DEFENSE: get_defense(),
		AGILITY: get_agility(),
		MAGIC: {
			ElementalStats.Element.EARTH: get_magic(ElementalStats.Element.EARTH),
			ElementalStats.Element.FIRE: get_magic(ElementalStats.Element.FIRE),
			ElementalStats.Element.WATER: get_magic(ElementalStats.Element.WATER),
			ElementalStats.Element.WIND: get_magic(ElementalStats.Element.WIND),
		},
		RESISTANCE: {
			ElementalStats.Element.EARTH: get_resistance(ElementalStats.Element.EARTH),
			ElementalStats.Element.FIRE: get_resistance(ElementalStats.Element.FIRE),
			ElementalStats.Element.WATER: get_resistance(ElementalStats.Element.WATER),
			ElementalStats.Element.WIND: get_resistance(ElementalStats.Element.WIND),
		}
	}


# Obtains the calculated value for a given stat.
func _get_calculated_stat(stat: int) -> int:
	match stat:
		CoreStats.Type.HEALTH:
			return core_stats.health_base + core_stats.health_growth * _level
		CoreStats.Type.ATTACK:
			return core_stats.attack_base + core_stats.attack_growth * _level
		CoreStats.Type.DEFENSE:
			return core_stats.defense_base + core_stats.defense_growth * _level
		CoreStats.Type.AGILITY:
			return core_stats.agility_base + core_stats.agility_growth * _level
		CoreStats.Type.MOVEMENT:
			return core_stats.movement
		_:
			return 0


# Obtains the calculated value for a given elemental stat.
func _get_calculated_elemental_stat(stat: int, element: int) -> int:
	match stat:
		ElementalStats.Type.MAGIC:
			return _magic_for_level(element)
		ElementalStats.Type.RESISTANCE:
			return _resistance_for_level(element)
		_:
			return 0


# Determines the value of a specified magic element for a given level.
func _magic_for_level(element: int) -> int:
	match element:
		ElementalStats.Element.EARTH:
			return (
					elemental_stats.magic_earth_base
					+ elemental_stats.magic_earth_growth
					* _level
			)
		ElementalStats.Element.FIRE:
			return (
					elemental_stats.magic_fire_base
					+ elemental_stats.magic_fire_growth
					* _level
			)
		ElementalStats.Element.WATER:
			return (
					elemental_stats.magic_water_base
					+ elemental_stats.magic_water_growth
					* _level
			)
		ElementalStats.Element.WIND:
			return (
					elemental_stats.magic_wind_base
					+ elemental_stats.magic_wind_growth
					* _level
			)
		_:
			return 0


# Determines the value of a specified resistance element for a given level.
func _resistance_for_level(element: int) -> int:
	match element:
		ElementalStats.Element.EARTH:
			return (
					elemental_stats.res_earth_base
					+ elemental_stats.res_earth_growth
					* _level
			)
		ElementalStats.Element.FIRE:
			return (
					elemental_stats.res_fire_base
					+ elemental_stats.res_fire_growth
					* _level
			)
		ElementalStats.Element.WATER:
			return (
					elemental_stats.res_water_base
					+ elemental_stats.res_water_growth
					* _level
			)
		ElementalStats.Element.WIND:
			return (
					elemental_stats.res_wind_base
					+ elemental_stats.res_wind_growth
					* _level
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
			core_stats != null,
			ErrorUtil.missing_required_parameter(self.name, "core_stats")
	)
	assert(
			core_stats is CoreStats,
			"Error: CharacterStat core_stats is not of type CoreStats. "
	)
	assert(
			elemental_stats != null,
			ErrorUtil.missing_required_parameter(self.name, "elemental_stats")
	)
	assert(
			elemental_stats is ElementalStats,
			"Error: CharacterStat elemental_stats is not of type ElementalStats."
	)
