@tool
class_name AlignmentArea
extends Area3D
## Defines an area that has a specific elemental alignment.
##
## Detects when a player avatar enters, updating the ElementalAlignment autoload
## to match the alignment of the area.


## The collision layer that colliders default to when created.
const DEFAULT_LAYER := 1
## The collision layer for map objects.
const MAP_LAYER := 3 
## The collision layer for player characters.
const PLAYER_LAYER := 2


@export_group("Light Alignment", "light")
## The first element aligned with light.
@export var light_element_1 : Element.Core = Element.Core.FIRE:
	set(value):
		var old_value := light_element_1
		light_element_1 = value
		_update_alignment(value, old_value, Element.Alignment.LIGHT, 1)
## The second element aligned with light.
@export var light_element_2 : Element.Core = Element.Core.WIND:
	set(value):
		var old_value := light_element_2
		light_element_2 = value
		_update_alignment(value, old_value, Element.Alignment.LIGHT, 2)
@export_group("Dark Alignment", "dark")
## The first element aligned with dark.
@export var dark_element_1 : Element.Core = Element.Core.EARTH:
	set(value):
		var old_value := dark_element_1
		dark_element_1 = value
		_update_alignment(value, old_value, Element.Alignment.DARK, 1)
## The second element aligned with dark.
@export var dark_element_2 : Element.Core = Element.Core.WATER:
	set(value):
		var old_value := dark_element_2
		dark_element_2 = value
		_update_alignment(value, old_value, Element.Alignment.DARK, 2)


## Creates a new CollisionShape if none is present.
func _ready() -> void:
	var body_entered_callable := Callable(self, "_on_AlignmentArea_body_entered")
	if not is_connected("body_entered", body_entered_callable):
		connect("body_entered", body_entered_callable)
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
	set_collision_layer_value(DEFAULT_LAYER, false)
	set_collision_layer_value(MAP_LAYER, true)
	set_collision_mask_value(DEFAULT_LAYER, false)
	set_collision_mask_value(PLAYER_LAYER, true)


## Updates the element of the alignment slot of the reference element. The
## alignment and slot values are the alignment slot that should be ignored.
func _update_alignment(
	reference_element: Element.Core,
	new_element: Element.Core,
	alignment_ignore: Element.Alignment,
	slot_ignore: int
) -> void:
	if (
		not is_node_ready()
		or reference_element == new_element
		or _all_core_present()
	):
		return
	if (
		light_element_1 == reference_element
		and (
			alignment_ignore != Element.Alignment.LIGHT
			or slot_ignore != 1
		)
	):
		light_element_1 = new_element
	elif (
		light_element_2 == reference_element
		and (
			alignment_ignore != Element.Alignment.LIGHT
			or slot_ignore != 2
		)
	):
		light_element_2 = new_element
	elif (
		dark_element_1 == reference_element
		and (
			alignment_ignore != Element.Alignment.DARK
			or slot_ignore != 1
		)
	):
		dark_element_1 = new_element
	elif (
		dark_element_2 == reference_element
		and (
			alignment_ignore != Element.Alignment.DARK
			or slot_ignore != 2
		)
	):
		dark_element_2 = new_element


## Checks that all alignment slots have unique core elements.
func _all_core_present() -> bool:
	var element_set: Dictionary[Element.Core, bool] = {}
	for element: Element.Core in Element.Core.values():
		element_set[element] = false
	element_set[light_element_1] = true
	element_set[light_element_2] = true
	element_set[dark_element_1] = true
	element_set[dark_element_2] = true
	return not element_set.values().has(false)


## Updates the elemental alignment.
func _on_AlignmentArea_body_entered(_avatar: Node3D) -> void:
	ElementalAlignment.set_element_alignments(
			light_element_1,
			light_element_2,
			dark_element_1,
			dark_element_2
	)
