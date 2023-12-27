class_name CoreStats
extends Object
"""
Contains the stats shared by all characters. Contains methods for accessing
and modifying said stats.
"""


# Describes a resistance type
enum ResistanceType {FIRE, EARTH, WATER, WIND}

# The maximum value of a character's health
var _base_max_hp: int = 0 setget set_max_hp, get_max_hp
# The strength of techniques
var _base_atk: int = 0 setget set_atk, get_atk
# The resistance value to techniques
var _base_def: int = 0 setget set_def, get_def
# The strength of spells
var _base_magic: int = 0 setget set_magic, get_magic
# Determines a character's initiative order
var _base_agl: int = 0 setget set_agl, get_agl
# The resistance value to elemental damage
var _resistances: Dictionary = {
	ResistanceType.FIRE: 0,
	ResistanceType.EARTH: 0,
	ResistanceType.WATER: 0,
	ResistanceType.WIND: 0,
} setget set_resistances, get_resistances


func set_max_hp(value: int):
	_base_max_hp = value if value >= 0 else 0


func get_max_hp() -> int:
	return _base_max_hp


func set_atk(value: int):
	_base_atk = value if value >= 0 else 0


func get_atk() -> int:
	return _base_atk


func set_def(value: int):
	_base_def = value if value >= 0 else 0


func get_def() -> int:
	return _base_def


func set_magic(value):
	_base_magic = value if value >= 0 else 0


func get_magic() -> int:
	return _base_magic


func set_agl(value: int):
	_base_agl = value if value >= 0 else 0


func get_agl() -> int:
	return _base_agl


func set_resistances(values: Dictionary):
	for element in values.keys():
		if values.has(element):
			_resistances[element] = values[element]


func get_resistances() -> Dictionary:
	return _resistances
