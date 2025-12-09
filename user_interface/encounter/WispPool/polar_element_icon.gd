@tool
class_name AlignmentElementIcon
extends TextureRect
## Represents a polar element in the UI: light or dark. Manages the shine of
## the icon.


## Indicates that the polar element has shined.
signal shine_ping(e)

@export var element: int = Element.Alignment.LIGHT: set = set_element
@export var light_region: Vector2 = Vector2(0,0)
@export var dark_region: Vector2 = Vector2(0,0)

@onready var ap: AnimationPlayer = $AnimationPlayer


## Sets the icon texture region to display the new element.
func set_element(new_element: int) -> void:
	match new_element:
		Element.Alignment.LIGHT:
			texture.region.position = light_region
		Element.Alignment.DARK:
			texture.region.position = dark_region
		_:
			return
	element = new_element


## Plays the shine animation of the given polar element.
func shine() -> void:
	if element == Element.Alignment.LIGHT:
		ap.play("light_shine")
	elif element == Element.Alignment.DARK:
		ap.play("dark_shine")


## Called when the node enters the scene tree for the first time.
func _ready():
	_check_for_required_parameters()


## Checks that all required parameters are given.
func _check_for_required_parameters() -> void:
	assert(texture is AtlasTexture, "Icon texture is not an AtlasTexture.")


## Called during the shine animation of the corresponding element. Emits a ping.
func _emit_ping() -> void:
	emit_signal("shine_ping", element)
