extends Node
## Defines the alignment of the four core elements. 
##
## The core elements are Earth, Fire, Water, Wind. The alignment are Light,
## Dark. Each alignment always has two core elements.


## Indicates that the alignment of core elements has changed.
signal alignment_changed()

## Shorthand for the LIGHT elemental alignment.
const LIGHT: Element.Alignment = Element.Alignment.LIGHT
## Shorthand for the DARK elemental alignment.
const DARK: Element.Alignment = Element.Alignment.DARK

## The elements that are aligned with Light.
var _light_elements: Array[Element.Core] = [Element.Core.FIRE, Element.Core.WIND]
## The elements that are aligned with Dark.
var _dark_elements: Array[Element.Core] = [Element.Core.EARTH, Element.Core.WATER]


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_set_to_default()


## Swap the alignments of the given elements.
func swap_elements(element_1: Element.Core, element_2: Element.Core) -> void:
	if (
		not _is_valid_core_element(element_1)
		or not _is_valid_core_element(element_2)
	):
		printerr("Cannot swap the alignment of a nonexistant core element.")
		return
	var element_1_details: Array[int] = _get_alignment_and_index(element_1)
	var element_2_details: Array[int] = _get_alignment_and_index(element_2)
	var element_1_alignment: Array[Element.Core] = (
		_light_elements if element_1_details[0] == LIGHT else _dark_elements
	)
	var element_2_alignment: Array[Element.Core] = (
		_light_elements if element_2_details[0] == LIGHT else _dark_elements
	)
	element_1_alignment[element_1_details[1]] = element_2
	element_2_alignment[element_1_details[1]] = element_1
	emit_signal("alignment_changed")


## Swap the alignments of all elements.
func invert_all_alignments() -> void:
	_swap_alignments_at_index(0)
	_swap_alignments_at_index(1)
	emit_signal("alignment_changed")


## Swap the alignments of the elements on the left side of the hex.
## Corresponds to index 0 of each alignment array.
func invert_left_alignments() -> void:
	_swap_alignments_at_index(0)
	emit_signal("alignment_changed")


## Swap the alignments of the elements on the right side of the hex.
## Corresponds to index 1 of each alignment array.
func invert_right_alignments() -> void:
	_swap_alignments_at_index(1)
	emit_signal("alignment_changed")


## Shift the alignments of all elements "counter-clockwise".
## L: [0, 1] => [1, 3]
## D: [2, 3] => [0, 2]
func shift_alignments_ccw() -> void:
	var first_light_element: Element.Core = _light_elements[0]
	_light_elements[0] = _light_elements[1]
	_light_elements[1] = _dark_elements[1]
	_dark_elements[1] = _dark_elements[0]
	_dark_elements[0] = first_light_element
	emit_signal("alignment_changed")


## Shift the polarities of all elements "clockwise".
## L: [0, 1] => [2, 0]
## D: [2, 3] => [3, 1]
func shift_alignments_cw() -> void:
	var first_light_element: Element.Core = _light_elements[0]
	_light_elements[0] = _dark_elements[0]
	_dark_elements[0] = _dark_elements[1]
	_dark_elements[1] = _light_elements[1]
	_light_elements[1] = first_light_element
	emit_signal("alignment_changed")


## Changes the elements that are of the Light alignment.
func set_elements_to_light(
	element_1: Element.Core,
	element_2: Element.Core
) -> void:
	if (
		not _is_valid_core_element(element_1)
		or not _is_valid_core_element(element_2)
	):
		printerr("Cannot assign alignment to a non-core element.")
		return
	_set_elements_to_alignment(LIGHT, element_1, element_2)
	emit_signal("alignment_changed")


## Changes the elements that are of the Dark alignment.
func set_elements_to_dark(element_1: int, element_2: int) -> void:
	if (
		not _is_valid_core_element(element_1)
		or not _is_valid_core_element(element_2)
	):
		printerr("Cannot assign alignment to a non-core element.")
		return
	_set_elements_to_alignment(DARK, element_1, element_2)
	emit_signal("alignment_changed")


## Updates the elements to have the specified alignments.
func set_element_alignments(
	light_1: Element.Core,
	light_2: Element.Core,
	dark_1: Element.Core,
	dark_2: Element.Core
) -> void:
	var element_set: Dictionary[Element.Core, bool] = {}
	for element: Element.Core in [light_1, light_2, dark_1, dark_2]:
		if element_set.has(element):
			printerr("Attempted to set element duplicates to alignments.")
			return
		element_set[element] = true
	_light_elements[0] = light_1
	_light_elements[1] = light_2
	_dark_elements[0] = dark_1
	_dark_elements[1] = dark_2
	emit_signal("alignment_changed")


## Get the elements of the Light alignment.
func get_light_elements() -> Array[Element.Core]:
	return _light_elements


## Get the elements of the Dark alignment.
func get_dark_elements() -> Array[Element.Core]:
	return _dark_elements


## Gets the alignment of the given element, as defined by the Constants enum,
## AlignmentElement.
func get_alignment(element: Element.Type) -> Element.Alignment:
	if element == LIGHT or element == DARK:
		return element as Element.Alignment
	elif element == _light_elements[0] or element == _light_elements[1]:
		return LIGHT
	else:
		return DARK


## Sets the two elements to the specified alignment.
func _set_elements_to_alignment(
	target_alignment: Element.Alignment,
	element_1: Element.Core,
	element_2: Element.Core
) -> void:
	var inverse_alignment: int = LIGHT if target_alignment == DARK else DARK
	var element_1_details: Array[int] = _get_alignment_and_index(element_1)
	var element_2_details: Array[int] = _get_alignment_and_index(element_2)
	
	if (
		element_1_details[0] == inverse_alignment
		and element_2_details[0] == inverse_alignment
	):
		_swap_alignments_at_index(element_1_details[1])
		_swap_alignments_at_index(element_2_details[1])
	elif (
		element_1_details[0] == inverse_alignment
		and element_2_details[0] == target_alignment
	):
		if element_1_details[1] != element_2_details[1]:
			_swap_alignments_at_index(element_1_details[1])
		elif element_1_details[1] == 0:
			shift_alignments_ccw()
		else:
			shift_alignments_cw()
	elif (
		element_1_details[0] == target_alignment
		and element_2_details[0] == inverse_alignment
	):
		if element_1_details[1] != element_2_details[1]:
			_swap_alignments_at_index(element_2_details[1])
		elif element_2_details[1] == 0:
			shift_alignments_cw()
		else:
			shift_alignments_ccw()
	if target_alignment == LIGHT:
		_light_elements[0] = element_1
		_light_elements[1] = element_2
	else:
		_dark_elements[0] = element_1
		_dark_elements[1] = element_2


## Gets the alignment and index of a given element. Returns the details in an
## array: [alignment, index]
func _get_alignment_and_index(element: Element.Core) -> Array[int]:
	for i: int in 2:
		if _light_elements[i] == element:
			return [LIGHT, i]
		elif _dark_elements[i] == element:
			return [DARK, i]
	return [-1, -1]


## Swap the elements at the given index for each alignment.
func _swap_alignments_at_index(index: int) -> void:
	var light_element: Element.Core = _light_elements[index]
	_light_elements[index] = _dark_elements[index]
	_dark_elements[index] = light_element


## Checks if a given value corresponds to an elemental type.
func _is_valid_core_element(element: int) -> bool:
	return element in Element.Core.values()


## Sets Fire and Wind to Light. Sets Earth and Water to Dark.
func _set_to_default() -> void:
	_light_elements[0] = Element.Core.FIRE
	_light_elements[1] = Element.Core.WIND
	_dark_elements[0] = Element.Core.EARTH
	_dark_elements[1] = Element.Core.WATER
