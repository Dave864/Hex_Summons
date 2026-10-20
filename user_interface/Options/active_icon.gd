@tool
class_name ActiveIcon
extends TextureRect
## Icon that indicates if something is active or not.
##
## Unlike a checkbox this icon is meant to be a visual indicator, not something
## that can be interacted with. Requires the specification of two different
## textures, one for inactive and the other for active.


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


## Sets the texture.
func _ready() -> void:
	_set_texture()


## Sets the texture to match the active flag.
func _set_texture() -> void:
	texture = active_texture if is_active else inactive_texture
