extends Node
## Defines the alignment of the four core elements. 
##
## The core elements are Earth, Fire, Water, Wind. The alignment are Light,
## Dark. Each alignment always has two core elements.


## Indicates that the alignment of core elements has changed.
signal alignment_changed()

const LIGHT: Element.Alignment = Element.Alignment.LIGHT
const DARK: Element.Alignment = Element.Alignment.DARK

var _alignments: Dictionary[Element.Alignment, Array] = {
	LIGHT: [-1, -1],
	DARK: [-1, -1],
}


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_set_to_default()


## Swap the alignments of the given elements.
func swap_elements(element_1: int, element_2: int) -> void:
	if (
		not _is_valid_core_element(element_1)
		or not _is_valid_core_element(element_2)
	):
		printerr("Cannot swap the alignment of a nonexistant core element.")
		return
	var element_1_details: Array[int] = _get_alignment_and_index(element_1)
	var element_2_details: Array[int] = _get_alignment_and_index(element_2)
	_alignments[element_1_details[0]][element_1_details[1]] = element_2
	_alignments[element_2_details[0]][element_2_details[1]] = element_1
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
	var first_light_element: int = _alignments[LIGHT][0]
	_alignments[LIGHT][0] = _alignments[LIGHT][1]
	_alignments[LIGHT][1] = _alignments[DARK][1]
	_alignments[DARK][1] = _alignments[DARK][0]
	_alignments[DARK][0] = first_light_element
	emit_signal("alignment_changed")


## Shift the polarities of all elements "clockwise".
## L: [0, 1] => [2, 0]
## D: [2, 3] => [3, 1]
func shift_alignments_cw() -> void:
	var first_light_element: int = _alignments[LIGHT][0]
	_alignments[LIGHT][0] = _alignments[DARK][0]
	_alignments[DARK][0] = _alignments[DARK][1]
	_alignments[DARK][1] = _alignments[LIGHT][1]
	_alignments[LIGHT][1] = first_light_element
	emit_signal("alignment_changed")


## Changes the elements that are of the Light alignment.
func set_elements_to_light(element_1: int, element_2: int) -> void:
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


## Get the elements of the Light alignment.
func get_light_elements() -> Array[Element.Core]:
	return _alignments[LIGHT]


## Get the elements of the Dark alignment.
func get_dark_elements() -> Array[Element.Core]:
	return _alignments[DARK]


## Gets the alignment of the given element, as defined by the Constants enum,
## AlignmentElement.
func get_alignment(element: int) -> int:
	if element == LIGHT or element == DARK:
		return element
	elif element == _alignments[LIGHT][0] or element == _alignments[LIGHT][1]:
		return LIGHT
	elif element == _alignments[DARK][0] or element == _alignments[DARK][1]:
		return DARK
	else:
		return -1


## Sets the two elements to the specified alignment.
func _set_elements_to_alignment(
	target_alignment: int,
	element_1: int,
	element_2: int
) -> void:
	if target_alignment in Element.Alignment.keys():
		printerr("target_alignment is not a 'polar' element.")
		return
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
		else:
			if element_1_details[1] == 0:
				shift_alignments_ccw()
			else:
				shift_alignments_cw()
	elif (
		element_1_details[0] == target_alignment
		and element_2_details[0] == inverse_alignment
	):
		if element_1_details[1] != element_2_details[1]:
			_swap_alignments_at_index(element_2_details[1])
		else:
			if element_2_details[1] == 0:
				shift_alignments_cw()
			else:
				shift_alignments_ccw()
	_alignments[target_alignment][0] = element_1
	_alignments[target_alignment][1] = element_2


## Gets the alignment and index of a given element. Returns the details in an
## array: [alignment, index]
func _get_alignment_and_index(element: int) -> Array[int]:
	for p: Element.Alignment in _alignments:
		for i: int in len(p):
			if _alignments[p][i] == element:
				return [p, i]
	return [-1, -1]


## Swap the elements at the given index for each alignment.
func _swap_alignments_at_index(index: int) -> void:
	var light_element: int = _alignments[LIGHT][index]
	_alignments[LIGHT][index] = _alignments[DARK][index]
	_alignments[DARK][index] = light_element


## Checks if a given value corresponds to an elemental type.
func _is_valid_core_element(element: int) -> bool:
	return element in Element.Core.keys()


## Sets Fire and Wind to Light. Sets Earth and Water to Dark.
func _set_to_default() -> void:
	_alignments[LIGHT][0] = Element.Core.FIRE
	_alignments[LIGHT][1] = Element.Core.WIND
	_alignments[DARK][0] = Element.Core.EARTH
	_alignments[DARK][1] = Element.Core.WATER
