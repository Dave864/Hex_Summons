@tool
class_name CoreElementIcon
extends TextureRect
"""
Represents a core element in the UI: earth, fire, water, or wind. Manages
the changes from one element to another.
"""


signal element_ping(e)

@export var element: int = Constants.CoreElement.EARTH: set = set_element
@export var earth_region: Vector2 = Vector2(0,0)
@export var fire_region: Vector2 = Vector2(0,0)
@export var water_region: Vector2 = Vector2(0,0)
@export var wind_region: Vector2 = Vector2(0,0)

var _ping: bool = false

@onready var ap: AnimationPlayer = $AnimationPlayer


# Sets the icon texture region to display the new element.
func set_element(new_element: int) -> void:
	match new_element:
		Constants.CoreElement.EARTH:
			texture.region.position = earth_region
		Constants.CoreElement.FIRE:
			texture.region.position = fire_region
		Constants.CoreElement.WATER:
			texture.region.position = water_region
		Constants.CoreElement.WIND:
			texture.region.position = wind_region
		_:
			return
	element = new_element


# Changes the icon to match the new element, playing the corresponding animations
# and signaling when the elements change.
func change_element(new_element: int, ping: bool = true) -> void:
	_ping = ping
	match element:
		Constants.CoreElement.EARTH:
			ap.play("earth_from")
		Constants.CoreElement.FIRE:
			ap.play("fire_from")
		Constants.CoreElement.WATER:
			ap.play("water_from")
		Constants.CoreElement.WIND:
			ap.play("wind_from")
	match new_element:
		Constants.CoreElement.EARTH:
			ap.queue("earth_to")
		Constants.CoreElement.FIRE:
			ap.queue("fire_to")
		Constants.CoreElement.WATER:
			ap.queue("water_to")
		Constants.CoreElement.WIND:
			ap.queue("wind_to")
	set_element(new_element)


# Called when the node enters the scene tree for the first time.
func _ready():
	# Keep the icon from using the RESET position when set to default element.
	if element == Constants.CoreElement.EARTH:
		texture.region.position = earth_region
	_check_for_required_parameters()


# Checks that all required parameters are given.
func _check_for_required_parameters() -> void:
	assert(texture is AtlasTexture, "Icon texture is not an AtlasTexture.")


# Called during the a "from" animation. Emits a ping.
func _emit_ping() -> void:
	if _ping:
		emit_signal("element_ping", element)
