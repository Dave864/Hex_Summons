class_name ElementalPolarity
extends Node
"""
Defines the polarity of the four core elements. 
The core elements are Earth, Fire, Water, Wind. The polarities are Light, Dark.
Each polarity always has two core elements.
"""


const LIGHT: int = ElementalStat.Element.LIGHT
const DARK: int = ElementalStat.Element.DARK

var _polarities: Dictionary = {
	LIGHT: [-1, -1],
	DARK: [-1, -1],
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_set_to_default()


# Swap the polarities of the given elements.
func swap_elements(element_1: int, element_2: int) -> void:
	if (
		not element_1 in ElementalStat.Element.keys()
		or not element_2 in ElementalStat.Element.keys()
	):
		printerr("Cannot swap the polarity of a nonexistant element.")
		return
	if (
		element_1 == LIGHT
		or element_1 == DARK
		or element_2 == LIGHT
		or element_2 == DARK
	):
		printerr("Cannot swap polarities of Light or Dark elements.")
		return
	var element_1_details: Array = _get_polarity_and_index(element_1)
	var element_2_details: Array = _get_polarity_and_index(element_2)
	_polarities[element_1_details[0]][element_1_details[1]] = element_2
	_polarities[element_2_details[0]][element_2_details[1]] = element_1


# Swap the polarities of all elements.
func invert_polarities() -> void:
	_swap_polarities_at_index(0)
	_swap_polarities_at_index(1)


# Get the elements of the Light polarity.
func get_light_elements() -> Array:
	return _polarities[LIGHT]


# Get the elements of the Dark polarity.
func get_dark_elements() -> Array:
	return _polarities[DARK]


# Gets the polarity of the given element, as defined by ElementalStat.
func get_element_polarity(element: int) -> int:
	if element == LIGHT or element == DARK:
		return element
	elif element == _polarities[LIGHT][0] or element == _polarities[LIGHT][1]:
		return LIGHT
	else:
		return DARK


# Gets the polarity and index of a given element.
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


# Sets Fire and Wind to Light. Sets Earth and Water to Dark.
func _set_to_default() -> void:
	_polarities[LIGHT][0] = ElementalStat.Element.FIRE
	_polarities[LIGHT][1] = ElementalStat.Element.WIND
	_polarities[DARK][0] = ElementalStat.Element.EARTH
	_polarities[DARK][1] = ElementalStat.Element.WATER
