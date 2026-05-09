@tool
class_name StableAlignmentArea
extends AlignmentArea
## Defines an area that has a specific elemental alignment.


@export_group("Light Alignment", "light")
## The first element aligned with light.
@export var light_element_1 : Element.Core = Element.Core.FIRE:
	get:
		return _light_1_current
	set(value):
		_update_alignment(value, _light_1_current)
		_light_1_current = value
## The second element aligned with light.
@export var light_element_2 : Element.Core = Element.Core.WIND:
	get:
		return _light_2_current
	set(value):
		_update_alignment(value, _light_2_current)
		_light_2_current = value
@export_group("Dark Alignment", "dark")
## The first element aligned with dark.
@export var dark_element_1 : Element.Core = Element.Core.EARTH:
	get:
		return _dark_1_current
	set(value):
		_update_alignment(value, _dark_1_current)
		_dark_1_current = value
## The second element aligned with dark.
@export var dark_element_2 : Element.Core = Element.Core.WATER:
	get:
		return _dark_2_current
	set(value):
		_update_alignment(value, _dark_2_current)
		_dark_2_current = value


## Updates the alignment slot of the source element to be the new element.
func _update_alignment(source: Element.Core, new: Element.Core) -> void:
	if not is_node_ready() or source == new:
		return
	elif _light_1_current == source:
		_light_1_current = new
	elif _light_2_current == source:
		_light_2_current = new
	elif _dark_1_current == source:
		_dark_1_current = new
	elif _dark_2_current == source:
		_dark_2_current = new
	else:
		printerr("Unable to find alignment of source element.")
