class_name PlayerWispPool
extends WispPool
"""
Tracks the wisp states for a Player character.
"""

# Tracks which wisps are "active", i.e. which wisps are available to be used
# for actions.
var earth: Dictionary = {}
var fire: Dictionary = {}
var water: Dictionary = {}
var wind: Dictionary = {}


# Updates the state of the specified wisp to "active"
func set_active(wisp_key: int) -> void:
	if earth.has(wisp_key):
		pass
	if fire.has(wisp_key):
		pass
	if water.has(wisp_key):
		pass
	if wind.has(wisp_key):
		pass


# Called when the node enters the scene tree for the first time.
func _ready():
	for is_active in earth.values():
		_active_count[Constants.Element.EARTH] += 1 if is_active else 0
	for is_active in fire.values():
		_active_count[Constants.Element.FIRE] += 1 if is_active else 0
	for is_active in water.values():
		_active_count[Constants.Element.WATER] += 1 if is_active else 0
	for is_active in wind.values():
		_active_count[Constants.Element.WIND] += 1 if is_active else 0
