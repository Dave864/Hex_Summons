tool
class_name CoreStats
extends Resource
"""
Contains the stats shared by all characters. Contains methods for accessing
said stats.
TODO: update to only include relevant stats
"""


# Describes a resistance type.
enum Element {FIRE, EARTH, WATER, WIND}

# The maximum value of a character's health.
export(int, 1, 1000) var _base_max_hp = 1 setget , get_max_hp
# The strength of techniques.
export(int, 1, 1000) var _base_atk = 1 setget , get_atk
# The resistance value to techniques.
export(int, 1, 1000) var _base_def = 1 setget , get_def
# The strength of spells.
export(int, 1, 1000) var _base_magic = 1 setget , get_magic
# Determines a character's initiative order.
export(int, 1, 1000) var _base_agl = 1 setget , get_agl
# Determines how many spaces a character can move.
export(int, 1, 20) var _base_mvmt = 3 setget , get_mvmt

# The current health value of the character
var _current_hp: int setget set_current_hp, get_current_hp
# The rate at which the character moves from one tile to another.
var _mvmt_speed: float setget , get_mvmt_speed
# The resistance values to elemental damage.
var _base_res_earth: int
var _base_res_fire: int
var _base_res_water: int
var _base_res_wind: int


func get_max_hp() -> int:
	return _base_max_hp


func get_atk() -> int:
	return _base_atk


func get_def() -> int:
	return _base_def


func get_magic() -> int:
	return _base_magic


func get_agl() -> int:
	return _base_agl


func get_mvmt() -> int:
	return _base_mvmt


func set_current_hp(new_hp: int) -> void:
	"""
	TODO: update to account for scaled max_hp
	"""
	if new_hp > _base_max_hp:
		_current_hp = _base_max_hp
	elif new_hp < 0:
		_current_hp = 0
	else:
		_current_hp = new_hp


func get_current_hp() -> int:
	return _current_hp


func get_mvmt_speed() -> float:
	return _mvmt_speed


func get_resistance(element: int) -> int:
	match element:
		Element.EARTH:
			return _base_res_earth
		Element.FIRE:
			return _base_res_fire
		Element.WATER:
			return _base_res_water
		Element.WIND:
			return _base_res_wind
		_:
			printerr(
				"Provided element index %d does not match any valid " + \
				"element. Valid indices are from 0-3." % \
				[element]
			)
			return -1


func can_property_revert(property: String) -> bool:
	match property:
		"_mvmt_speed":
			return true
		"_base_res_earth":
			return true
		"_base_res_fire":
			return true
		"_base_res_water":
			return true
		"_base_res_wind":
			return true
		_:
			return false


func property_get_revert(property: String) -> float:
	match property:
		"_mvmt_speed":
			return 5.0
		"_base_res_earth":
			return 1.0
		"_base_res_fire":
			return 1.0
		"_base_res_water":
			return 1.0
		"_base_res_wind":
			return 1.0
		_:
			return 0.0


func _get_property_list() -> Array:
	var properties: Array = []
	
	# Add movement speed property.
	properties.append({
		name = "_mvmt_speed",
		type = TYPE_REAL,
		hint = PROPERTY_HINT_RANGE,
		hint_string = "1.0, 10.0, 1.0"
	})
	
	# Set up the Resistances parameter group.
	properties.append({
		name = "Base Resistances",
		type = TYPE_NIL,
		hint_string = "_base_res_",
		usage = PROPERTY_USAGE_GROUP | PROPERTY_USAGE_SCRIPT_VARIABLE
	})
	
	# Add Earth element resistance property.
	properties.append({
		name = "_base_res_earth",
		type = TYPE_INT,
		hint = PROPERTY_HINT_RANGE,
		hint_string = "1, 1_000"
	})
	
	# Add Fire element resistance property.
	properties.append({
		name = "_base_res_fire",
		type = TYPE_INT,
		hint = PROPERTY_HINT_RANGE,
		hint_string = "1, 1_000"
	})
	
	# Add Water element resistance property.
	properties.append({
		name = "_base_res_water",
		type = TYPE_INT,
		hint = PROPERTY_HINT_RANGE,
		hint_string = "1, 1_000"
	})
	
	# Add Wind element resistance property.
	properties.append({
		name = "_base_res_wind",
		type = TYPE_INT,
		hint = PROPERTY_HINT_RANGE,
		hint_string = "1, 1_000"
	})
	
	return properties


func _init(
	p_base_max_hp: int = 1, 
	p_base_atk: int = 1,
	p_base_def: int = 1,
	p_base_magic: int = 1,
	p_base_agl: int = 1,
	p_base_mvmt: int = 3,
	p_res_earth: int = 1,
	p_res_fire: int = 1,
	p_res_water: int = 1,
	p_res_wind: int = 1
) -> void:
	_mvmt_speed = 5.0
	_current_hp = p_base_max_hp
	_base_max_hp = p_base_max_hp
	_base_atk = p_base_atk
	_base_def = p_base_def
	_base_magic = p_base_magic
	_base_agl = p_base_agl
	_base_mvmt = p_base_mvmt
	_base_res_earth = p_res_earth
	_base_res_fire = p_res_fire
	_base_res_water = p_res_water
	_base_res_wind = p_res_wind

