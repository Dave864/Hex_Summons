@tool
class_name CoreElementIcon
extends TextureRect
## Represents a core element in the UI: earth, fire, water, or wind. Also allows
## for a blank element. Manages the changes from one element to another.


## Indicates that the element value should change.
signal element_ping(e)

## The element currently being displayed. Set as int to allow for -1 to be used.
@export var element: int = Element.Core.EARTH:
	set = set_element
## The starting point of the texture region for the earth element icon.
@export var earth_region := Vector2(0,0)
## The starting point of the texture region for the fire element icon.
@export var fire_region := Vector2(0,0)
## The starting point of the texture region for the water element icon.
@export var water_region := Vector2(0,0)
## The starting point of the texture region for the wind element icon.
@export var wind_region := Vector2(0,0)
## The starting point of the texture region for the blank element icon.
@export var blank_region := Vector2(0,0)

## Internal flag that indicates if the element ping should be emitted during
## the animation.
var _ping: bool = false

## The AnimationPlayer for the texture.
@onready var ap: AnimationPlayer = $AnimationPlayer


## Called when the node enters the scene tree for the first time.
func _ready():
	# Keep the icon from using the RESET position when set to default element.
	if element == Element.Core.EARTH:
		texture.region.position = earth_region
	_check_for_required_parameters()


## Sets the icon texture region to display the new element. A -1 indicates that
## the blank texture should be used.
func set_element(new_element: int = -1) -> void:
	match new_element:
		Element.Core.EARTH:
			texture.region.position = earth_region
		Element.Core.FIRE:
			texture.region.position = fire_region
		Element.Core.WATER:
			texture.region.position = water_region
		Element.Core.WIND:
			texture.region.position = wind_region
		_:
			texture.region.position = blank_region
	element = new_element


## Changes the icon to match the new element, playing the corresponding animations
## and signaling when the elements change.
func change_element(new_element: int, ping: bool = true) -> void:
	_ping = ping
	match element:
		Element.Core.EARTH:
			ap.play("earth_from")
		Element.Core.FIRE:
			ap.play("fire_from")
		Element.Core.WATER:
			ap.play("water_from")
		Element.Core.WIND:
			ap.play("wind_from")
		_:
			ap.play("blank_from")
	match new_element:
		Element.Core.EARTH:
			ap.queue("earth_to")
		Element.Core.FIRE:
			ap.queue("fire_to")
		Element.Core.WATER:
			ap.queue("water_to")
		Element.Core.WIND:
			ap.queue("wind_to")
		_:
			ap.queue("blank_to")
	set_element(new_element)


## Checks that all required parameters are given.
func _check_for_required_parameters() -> void:
	assert(texture is AtlasTexture, "Icon texture is not an AtlasTexture.")


## Called during the a "from" animation from a non-blank element. Emits a ping
## if specified during the last change_element call.
func _emit_ping() -> void:
	if _ping:
		emit_signal("element_ping", element)
