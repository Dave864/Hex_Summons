class_name Character
extends Area
"""
Base class for players, mobs, and bosses. Contains a character's stats and map
position details.
"""


# The rate at which the character moves from one tile to another.
export(float, 1.0) var movement_time

# Basic Stats.
export(int, 1_000) var max_hp setget set_base_max_hp
export(int, 1_000) var atk setget set_base_atk
export(int, 1_000) var def setget set_base_def
export(int, 1_000) var magic setget set_base_magic
export(int, 1_000) var agl setget set_base_agl

# Resistances.
export(int, 1_000) var earth_res setget set_base_earth_res
export(int, 1_000) var fire_res setget set_base_fire_res
export(int, 1_000) var water_res setget set_base_water_res
export(int, 1_000) var wind_res setget set_base_wind_res

var stats: CoreStats = CoreStats.new()
var current_hp: int = 0

# Flag that indicates whether the creature has been set to its starting location.
var _start_set: bool = false
var _current_index: int = -1 setget , get_index_at

# References to the various attacks and spells the character has access to.
onready var _techniques: Array = $Techniques.get_children()
onready var _spells: Array = $Spells.get_children()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _on_Creature_area_entered(map_tile):
	_current_index = map_tile.get_index()
	# If the creature's start position has not been set, move it to the position
	# of the tile it in the area of.
	if !_start_set:
		_start_set = true
		translation = map_tile.translation


# Moves the character along to the points of the path.
func follow_path(path: Array):
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.EASE_IN_OUT)
	for point in path:
		tween.tween_property(self, "translation", point, movement_time)


# Get the index of the tile the character is currently at.
func get_index_at() -> int:
	return _current_index


func set_base_max_hp(value: int):
	max_hp = value
	stats.set_max_hp(max_hp)


func set_base_atk(value: int):
	atk = value
	stats.set_atk(atk)


func set_base_def(value: int):
	def = value
	stats.set_def(def)


func set_base_magic(value: int):
	magic = value
	stats.set_magic(magic)


func set_base_agl(value: int):
	agl = value
	stats.set_agl(agl)


func set_base_earth_res(value: int):
	earth_res = value
	stats.set_resistances({stats.ResistanceType.EARTH: earth_res})


func set_base_fire_res(value: int):
	fire_res = value
	stats.set_resistances({stats.ResistanceType.FIRE: fire_res})


func set_base_water_res(value: int):
	water_res = value
	stats.set_resistances({stats.ResistanceType.WATER: water_res})


func set_base_wind_res(value: int):
	wind_res = value
	stats.set_resistances({stats.ResistanceType.WIND: wind_res})
