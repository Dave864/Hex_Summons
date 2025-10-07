class_name WispPool
extends Node
"""
Tracks the wisp pool for a character in an encounter. 
"""


var earth: Dictionary = {}
var fire: Dictionary = {}
var water: Dictionary = {}
var wind: Dictionary = {}


# Gets the number of earth wisps that are active for actions.
func active_earth_count() -> int:
	return 0


# Gets the number of fire wisps that are active for actions.
func active_fire_count() -> int:
	return 0


# Gets the number of water wisps that are active for actions.
func active_water_count() -> int:
	return 0


# Gets the number of wind wisps that are active for actions.
func active_wind_count() -> int:
	return 0


# Gets the number of wind wisps that are active for actions.
func active_light_count() -> int:
	return 0


# Gets the number of wind wisps that are active for actions.
func active_dark_count() -> int:
	return 0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
