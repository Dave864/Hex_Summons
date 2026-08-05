@tool
@abstract
class_name AlignmentArea
extends Area3D
## Abstract class that tracks the elemental alignment of an area.
##
## Detects when a player avatar enters, updating the ElementalAlignment autoload
## to match the alignment of the area.


## The first element aligned with light.
var _light_1_current := Element.Core.FIRE
## The second element aligned with light.
var _light_2_current: = Element.Core.WIND
## The first element aligned with dark.
var _dark_1_current := Element.Core.EARTH
## The second element aligned with dark.
var _dark_2_current := Element.Core.WATER


## Creates a new CollisionShape if none is present.
func _ready() -> void:
	if not body_entered.is_connected(_on_AlignmentArea_body_entered):
		body_entered.connect(_on_AlignmentArea_body_entered)
	if get_shape_owners().size() == 0:
		var collision_shape := CollisionShape3D.new()
		add_child(collision_shape)
		if Engine.is_editor_hint():
			collision_shape.set_owner(get_tree().edited_scene_root)
		collision_shape.name = "CollisionShape3D"
		collision_shape.debug_color = Color.MAGENTA
		collision_shape.debug_fill = false
		collision_shape.shape = BoxShape3D.new()


## Creates a new instance of AlignmentArea.
func _init() -> void:
	set_collision_layer_value(Constants.DEFAULT_LAYER, false)
	set_collision_layer_value(Constants.MAP_LAYER, true)
	set_collision_mask_value(Constants.DEFAULT_LAYER, false)
	set_collision_mask_value(Constants.PLAYER_LAYER, true)


## Updates the elemental alignment.
func _on_AlignmentArea_body_entered(_avatar: OverworldAvatar) -> void:
	ElementalAlignment.set_element_alignments(
			_light_1_current,
			_light_2_current,
			_dark_1_current,
			_dark_2_current
	)
