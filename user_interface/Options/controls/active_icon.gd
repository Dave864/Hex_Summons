@tool
class_name ActiveIcon
extends TextureRect
## Icon that indicates if something is active or not.
##
## Unlike a checkbox this icon is meant to be a visual indicator, not something
## that can be interacted with. Requires the specification of two different
## textures, one for inactive and the other for active.


## The path to the image that will be the atlas for the default textures.
const TEXTURE_ATLAS_PATH := "res://art/ui/GlyphTheme2.png"

## The texture used for when the icon indicates the active state.
@export var active_texture: Texture2D = null:
	set(value):
		active_texture = value
		# Only want to set texture once when node is readying.
		if is_node_ready():
			_set_texture()
## The texture used for when the icon indicates the inactive stat.
@export var inactive_texture: Texture2D = null:
	set(value):
		inactive_texture = value
		# Only want to set texture once when node is readying.
		if is_node_ready():
			_set_texture()
## Whether the icon is active or not.
@export var is_active: bool = false:
	set(value):
		is_active = value
		# Only want to set texture once when node is readying.
		if is_node_ready():
			_set_texture()


## Creates an active icon using some default textures.
func _init() -> void:
	var atlas_image: CompressedTexture2D = load(TEXTURE_ATLAS_PATH)
	active_texture = AtlasTexture.new()
	active_texture.atlas = atlas_image
	active_texture.region = Rect2(35.0, 171.0, 11.0, 11.0)
	inactive_texture = AtlasTexture.new()
	inactive_texture.atlas = atlas_image
	inactive_texture.region = Rect2(49.0, 155.0, 9.0, 9.0)
	name = "ActiveIcon"


## Sets the texture.
func _ready() -> void:
	_set_texture()


## Sets the texture to match the active flag.
func _set_texture() -> void:
	texture = active_texture if is_active else inactive_texture
