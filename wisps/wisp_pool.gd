class_name WispPool
extends Node
## Base class for tracking the wisp pool for a character in an encounter. 


## This signal will be emitted in child classes.
@warning_ignore("unused_signal")
signal active_count_changed(element)

## The current number of wisps active in the pool.
var _active_count: Dictionary[Element.Core, int] = {
	Element.Core.EARTH: 0,
	Element.Core.FIRE: 0,
	Element.Core.WATER: 0,
	Element.Core.WIND: 0,
}


## Checks if there are any active wisps in the pool. Returns true if there are
## none.
func empty() -> bool:
	for element: Element.Core in _active_count.keys():
		if _active_count[element] > 0:
			return false
	return true


## Gets the number of active wisps for the specified element.
func active_element_count(element: Element.Type) -> int:
	if element == Element.Type.LIGHT:
		return active_light_count()
	if element == Element.Type.DARK:
		return active_dark_count()
	if not _active_count.has(element):
		printerr("Invalid element enum provided.")
		return -1
	return _active_count[element]


## Gets the number of earth wisps that are active for actions.
func active_earth_count() -> int:
	return _active_count[Element.Type.EARTH]


## Gets the number of fire wisps that are active for actions.
func active_fire_count() -> int:
	return _active_count[Element.Type.FIRE]


## Gets the number of water wisps that are active for actions.
func active_water_count() -> int:
	return _active_count[Element.Type.WATER]


## Gets the number of wind wisps that are active for actions.
func active_wind_count() -> int:
	return _active_count[Element.Type.WIND]


## Gets the total "strength" of light polarity wisps.
func active_light_count() -> int:
	var l_elems: Array[Element.Core] = ElementalAlignment.get_light_elements()
	return int(min(_active_count[l_elems[0]], _active_count[l_elems[1]]))


## Gets the total "strength" of dark polarity wisps.
func active_dark_count() -> int:
	var d_elems: Array[Element.Core] = ElementalAlignment.get_dark_elements()
	return int(min(_active_count[d_elems[0]], _active_count[d_elems[1]]))
