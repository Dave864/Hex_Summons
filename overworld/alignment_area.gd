@tool
class_name AlignmentArea
extends Area3D
## Defines an area that has a specific elemental alignment.
##
## Detects when a player avatar enters, updating the ElementalAlignment autoload
## to match the alignment of the area.


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


## Updates the element of the alignment slot of the reference element. The
## alignment and slot values are the alignment slot that should be ignored.
func _update_alignment(
	referece_element: Element.Core,
	new_element: Element.Core,
	alignment_ignore: Element.Alignment,
	slot_ignore: int
) -> void:
	if (
		not is_node_ready()
		or referece_element == new_element
		or _all_core_present()
	):
		return
	if (
		light_element_1 == referece_element
		and (
			alignment_ignore != Element.Alignment.LIGHT
			or slot_ignore != 1
		)
	):
		light_element_1 = new_element
	elif (
		light_element_2 == referece_element
		and (
			alignment_ignore != Element.Alignment.LIGHT
			or slot_ignore != 2
		)
	):
		light_element_2 = new_element
	elif (
		dark_element_1 == referece_element
		and (
			alignment_ignore != Element.Alignment.DARK
			or slot_ignore != 1
		)
	):
		dark_element_1 = new_element
	elif (
		dark_element_2 == referece_element
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
	ElementalAlignment.set_elements_to_light(light_element_1, light_element_2)
