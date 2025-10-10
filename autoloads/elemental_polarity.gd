extends Node
"""
Defines the polarity of the four core elements. 
The core elements are Earth, Fire, Water, Wind. The polarities are Light, Dark.
Each polarity always has two core elements.
"""


signal polarity_changed()

const LIGHT: int = Constants.PolarElement.LIGHT
const DARK: int = Constants.PolarElement.DARK

var _polarities: Dictionary = {
	LIGHT: [-1, -1],
	DARK: [-1, -1],
}


# Swap the polarities of the given elements.
func swap_elements(element_1: int, element_2: int) -> void:
	if (
		not _is_valid_core_element(element_1)
		or not _is_valid_core_element(element_2)
	):
		printerr("Cannot swap the polarity of a nonexistant core element.")
		return
	var element_1_details: Array = _get_polarity_and_index(element_1)
	var element_2_details: Array = _get_polarity_and_index(element_2)
	_polarities[element_1_details[0]][element_1_details[1]] = element_2
	_polarities[element_2_details[0]][element_2_details[1]] = element_1
	emit_signal("polarity_changed")


# Swap the polarities of all elements.
func invert_all_polarities() -> void:
	_swap_polarities_at_index(0)
	_swap_polarities_at_index(1)
	emit_signal("polarity_changed")


# Swap the polarities of the elements on the left side of the hex.
# Corresponds to index 0 of each polarity array.
func invert_left_polarities() -> void:
	_swap_polarities_at_index(0)
	emit_signal("polarity_changed")


# Swap the polarities of the elements on the right side of the hex.
# Corresponds to index 1 of each polarity array.
func invert_right_polarities() -> void:
	_swap_polarities_at_index(1)
	emit_signal("polarity_changed")


# Shift the polarities of all elements "counter-clockwise".
# L: [0, 1] => [1, 3]
# D: [2, 3] => [0, 2]
func shift_polarities_ccw() -> void:
	var first_light_element: int = _polarities[LIGHT][0]
	_polarities[LIGHT][0] = _polarities[LIGHT][1]
	_polarities[LIGHT][1] = _polarities[DARK][1]
	_polarities[DARK][1] = _polarities[DARK][0]
	_polarities[DARK][0] = first_light_element
	emit_signal("polarity_changed")


# Shift the polarities of all elements "clockwise".
# L: [0, 1] => [2, 0]
# D: [2, 3] => [3, 1]
func shift_polarities_cw() -> void:
	var first_dark_element: int = _polarities[DARK][0]
	_polarities[LIGHT][0] = _polarities[DARK][0]
	_polarities[DARK][0] = _polarities[DARK][1]
	_polarities[DARK][1] = _polarities[LIGHT][1]
	_polarities[LIGHT][1] = first_dark_element
	emit_signal("polarity_changed")


# Changes the elements that are of the Light polarity.
func set_elements_to_light(element_1: int, element_2: int) -> void:
	if (
		not _is_valid_core_element(element_1)
		or not _is_valid_core_element(element_2)
	):
		printerr("Cannot assign polarity to a non-core element.")
		return
	_set_elements_to_polarity(LIGHT, element_1, element_2)
	emit_signal("polarity_changed")


# Changes the elements that are of the Dark polarity.
func set_elements_to_dark(element_1: int, element_2: int) -> void:
	if (
		not _is_valid_core_element(element_1)
		or not _is_valid_core_element(element_2)
	):
		printerr("Cannot assign polarity to a non-core element.")
		return
	_set_elements_to_polarity(DARK, element_1, element_2)
	emit_signal("polarity_changed")


# Get the elements of the Light polarity.
func get_light_elements() -> Array:
	return _polarities[LIGHT]


# Get the elements of the Dark polarity.
func get_dark_elements() -> Array:
	return _polarities[DARK]


# Gets the polarity of the given element, as defined by ElementalStat.
func get_polarity(element: int) -> int:
	if element == LIGHT or element == DARK:
		return element
	elif element == _polarities[LIGHT][0] or element == _polarities[LIGHT][1]:
		return LIGHT
	elif element == _polarities[DARK][0] or element == _polarities[DARK][1]:
		return DARK
	else:
		return -1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_set_to_default()


# Sets the two elements to the specified polarity.
func _set_elements_to_polarity(
	target_polarity: int,
	element_1: int,
	element_2: int
) -> void:
	if target_polarity in Constants.PolarElement.keys():
		printerr("target_polarity is not a 'polar' element.")
		return
	var inverse_polarity: int = LIGHT if target_polarity == DARK else DARK
	var element_1_details: Array = _get_polarity_and_index(element_1)
	var element_2_details: Array = _get_polarity_and_index(element_2)
	
	if (
		element_1_details[0] == inverse_polarity
		and element_2_details[0] == inverse_polarity
	):
		_swap_polarities_at_index(element_1_details[1])
		_swap_polarities_at_index(element_2_details[1])
	elif (
		element_1_details[0] == inverse_polarity
		and element_2_details[0] == target_polarity
	):
		if element_1_details[1] != element_2_details[1]:
			_swap_polarities_at_index(element_1_details[1])
		else:
			if element_1_details[1] == 0:
				shift_polarities_ccw()
			else:
				shift_polarities_cw()
	elif (
		element_1_details[0] == target_polarity
		and element_2_details[0] == inverse_polarity
	):
		if element_1_details[1] != element_2_details[1]:
			_swap_polarities_at_index(element_2_details[1])
		else:
			if element_2_details[1] == 0:
				shift_polarities_cw()
			else:
				shift_polarities_ccw()
	_polarities[target_polarity][0] = element_1
	_polarities[target_polarity][1] = element_2


# Gets the polarity and index of a given element. Returns the details in an
# array: [polarity, index]
func _get_polarity_and_index(element: int) -> Array:
	for p in _polarities:
		for i in len(p):
			if _polarities[p][i] == element:
				return [p, i]
	return [-1, -1]


# Swap the elements at the given index for each polarity.
func _swap_polarities_at_index(index: int) -> void:
	var light_element: int = _polarities[LIGHT][index]
	_polarities[LIGHT][index] = _polarities[DARK][index]
	_polarities[DARK][index] = light_element


# Checks if a given value corresponds to an elemental type.
func _is_valid_core_element(element: int) -> bool:
	return element in Constants.CoreElement.keys()


# Sets Fire and Wind to Light. Sets Earth and Water to Dark.
func _set_to_default() -> void:
	_polarities[LIGHT][0] = Constants.CoreElement.FIRE
	_polarities[LIGHT][1] = Constants.CoreElement.WIND
	_polarities[DARK][0] = Constants.CoreElement.EARTH
	_polarities[DARK][1] = Constants.CoreElement.WATER
