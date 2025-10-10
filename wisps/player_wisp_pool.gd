class_name PlayerWispPool
extends WispPool
"""
Tracks the wisp states for a Player character.
"""


# Tracks which wisps are "active", i.e. which wisps are available to be used
# for actions.
var earth: Dictionary = {}
var fire: Dictionary = {}
var water: Dictionary = {}
var wind: Dictionary = {}


# Updates the state of the specified wisp to "active"
func set_active(wisp_key: int) -> void:
	var element: int
	if earth.has(wisp_key):
		element = Constants.CoreElement.EARTH
		earth[wisp_key] = true
	elif fire.has(wisp_key):
		element = Constants.CoreElement.FIRE
		fire[wisp_key] = true
	elif water.has(wisp_key):
		element = Constants.CoreElement.WATER
		water[wisp_key] = true
	elif wind.has(wisp_key):
		element = Constants.CoreElement.WIND
		wind[wisp_key] = true
	else:
		return
	_active_count[element] += 1
	emit_signal("active_count_changed", element)


# Gets the keys for the wisps that are used to pay for the specified element.
# Deactivates the wisps that are spent. Returns an empty array if no wisps
# are available for the given element.
func pay_for_element(element: int) -> Array:
	match element:
		Constants.Element.EARTH:
			var id: int = _deactivate_first_active(earth, element)
			if id >= 0:
				return [id]
		Constants.Element.FIRE:
			var id: int = _deactivate_first_active(fire, element)
			if id >= 0:
				return [id]
		Constants.Element.WATER:
			var id: int = _deactivate_first_active(water, element)
			if id >= 0:
				return [id]
		Constants.Element.WIND:
			var id: int = _deactivate_first_active(wind, element)
			if id >= 0:
				return [id]
		Constants.Element.LIGHT:
			var elems: Array = ElementalPolarity.get_light_elements()
			var ids: Array = _deactivate_polar_active(elems[0], elems[1])
			emit_signal("active_count_changed", element)
			return ids
		Constants.Element.DARK:
			var elems: Array = ElementalPolarity.get_dark_elements()
			var ids: Array = _deactivate_polar_active(elems[0], elems[1])
			emit_signal("active_count_changed", element)
			return ids
	return []


# Called when the node enters the scene tree for the first time.
func _ready():
	for is_active in earth.values():
		_active_count[Constants.CoreElement.EARTH] += 1 if is_active else 0
	for is_active in fire.values():
		_active_count[Constants.CoreElement.FIRE] += 1 if is_active else 0
	for is_active in water.values():
		_active_count[Constants.CoreElement.WATER] += 1 if is_active else 0
	for is_active in wind.values():
		_active_count[Constants.CoreElement.WIND] += 1 if is_active else 0


# Helper function for pay_for_element. Deactivates the first active wisp in the
# given category. Returns the key of said wisp, if any. Returns -1 if none are
# found.
func _deactivate_first_active(wisps: Dictionary, element: int) -> int:
	for id in wisps.keys():
		if wisps[id]:
			wisps[id] = false
			_active_count[element] -= 1
			emit_signal("active_count_changed", element)
			return id
	return -1


# Helper function for pay_for_element. Deactivates the first active wisps for the
# relevant polar elements. Return an empty array if not enough elements are
# active.
func _deactivate_polar_active(elem_1: int, elem_2: int) -> Array:
	if _active_count[elem_1] == 0 or _active_count[elem_2] == 0:
		return []
	return [
		_deactivate_first_active(_get_element_tracker(elem_1), elem_1),
		_deactivate_first_active(_get_element_tracker(elem_2), elem_2)
	]


# Gets the tracker Dictionary for the given element. Returns an empty Dictionary
# if no corresponding tracker is found.
func _get_element_tracker(element: int) -> Dictionary:
	match element:
		Constants.CoreElement.EARTH:
			return earth
		Constants.CoreElement.FIRE:
			return fire
		Constants.CoreElement.WATER:
			return water
		Constants.CoreElement.WIND:
			return wind
	return {}
