class_name WispPool
extends Node
"""
Base class for tracking the wisp pool for a character in an encounter. 
"""


var _active_count: Dictionary = {
	Constants.Element.EARTH: 0,
	Constants.Element.FIRE: 0,
	Constants.Element.WATER: 0,
	Constants.Element.WIND: 0,
}


# Gets the number of active wisps for the specified element.
func active_element_count(element: int) -> int:
	if element == Constants.Element.LIGHT:
		return active_light_count()
	if element == Constants.Element.DARK:
		return active_dark_count()
	if not _active_count.has(element):
		printerr("Invalid element enum provided.")
		return -1
	return _active_count[element]


# Gets the number of earth wisps that are active for actions.
func active_earth_count() -> int:
	return _active_count[Constants.Element.EARTH]


# Gets the number of fire wisps that are active for actions.
func active_fire_count() -> int:
	return _active_count[Constants.Element.FIRE]


# Gets the number of water wisps that are active for actions.
func active_water_count() -> int:
	return _active_count[Constants.Element.WATER]


# Gets the number of wind wisps that are active for actions.
func active_wind_count() -> int:
	return _active_count[Constants.Element.WIND]


# Gets the total "strength" of light polarity wisps.
func active_light_count() -> int:
	var l_elems: Array = ElementalPolarity.get_light_elements()
	return int(min(_active_count[l_elems[0]], _active_count[l_elems[1]]))


# Gets the total "strength" of dark polarity wisps.
func active_dark_count() -> int:
	var d_elems: Array = ElementalPolarity.get_dark_elements()
	return int(min(_active_count[d_elems[0]], _active_count[d_elems[1]]))
