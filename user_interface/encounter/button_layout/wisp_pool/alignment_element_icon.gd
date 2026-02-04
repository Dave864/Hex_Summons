@tool
class_name AlignmentElementIcon
extends TextureRect
## Represents a alignment element in the UI: light or dark. Manages the shine of
## the icon.


## Indicates that the polar element has shined.
signal shine_ping(e)

## The alignment element this icon represents.
@export var element: Element.Alignment = Element.Alignment.LIGHT:
	set = set_element
## The starting point for the texture region for a fully displayed light element.
@export var light_region: Vector2 = Vector2(0,0)
## The starting point for the texture region for a fully displayed dark element.
@export var dark_region: Vector2 = Vector2(0,0)

## The animation player for the icon shine.
@onready var ap: AnimationPlayer = $AnimationPlayer


## Called when the node enters the scene tree for the first time.
func _ready():
	# Keep the icon from using the RESET position when set to default element.
	if element == Element.Alignment.LIGHT:
		element = Element.Alignment.LIGHT
	_check_for_required_parameters()


## Sets the icon texture region to display the new element.
func set_element(new_element: Element.Alignment) -> void:
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


## Checks that all required parameters are given.
func _check_for_required_parameters() -> void:
	assert(texture is AtlasTexture, "Icon texture is not an AtlasTexture.")


## Called during the shine animation of the corresponding element. Emits a ping.
func _emit_ping() -> void:
	emit_signal("shine_ping", element)
