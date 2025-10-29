class_name PlayerWispPool
extends WispPool
"""
Tracks the wisp states for a Player character.
"""


const NONE: String = ""

var player_name: String = ""
# Tracks which wisps are "active", i.e. which wisps are available to be used
# for actions.
var earth: Dictionary = {}
var fire: Dictionary = {}
var water: Dictionary = {}
var wind: Dictionary = {}


# Adds wisp to the appropriate pool. Updates WispTracker.
func add_new_wisp(wisp: String) -> void:
	var element: int = WispTracker.wisp_element(wisp)
	match element:
		Constants.CoreElement.EARTH:
			earth[wisp] = false
		Constants.CoreElement.FIRE:
			fire[wisp] = false
		Constants.CoreElement.WATER:
			water[wisp] = false
		Constants.CoreElement.WIND:
			wind[wisp] = false
		_:
			printerr("Wisp {0} is not of valid element.".format([wisp]))
			return
	WispTracker.set_bonded_player(wisp, player_name)
	if WispTracker.is_player_set(wisp):
		set_active(wisp)


# Removes the wisp from the pool. Updates WispTracker.
func remove_wisp(wisp: String) -> void:
	if earth.has(wisp):
		if earth[wisp]:
			_active_count[Constants.CoreElement.EARTH] -= 1
		earth.erase(wisp)
	elif fire.has(wisp):
		if fire[wisp]:
			_active_count[Constants.CoreElement.FIRE] -= 1
		fire.erase(wisp)
	elif water.has(wisp):
		if water[wisp]:
			_active_count[Constants.CoreElement.WATER] -= 1
		water.erase(wisp)
	elif wind.has(wisp):
		if wind[wisp]:
			_active_count[Constants.CoreElement.WIND] -= 1
		wind.erase(wisp)
	else:
		return
	WispTracker.set_bonded_player(wisp)


# Updates the state of the specified wisp to "active"
func set_active(wisp: String) -> void:
	var element: int
	if earth.has(wisp):
		element = Constants.CoreElement.EARTH
		earth[wisp] = true
	elif fire.has(wisp):
		element = Constants.CoreElement.FIRE
		fire[wisp] = true
	elif water.has(wisp):
		element = Constants.CoreElement.WATER
		water[wisp] = true
	elif wind.has(wisp):
		element = Constants.CoreElement.WIND
		wind[wisp] = true
	else:
		return
	_active_count[element] += 1
	emit_signal("active_count_changed", element)


# Gets the keys for the wisps that are used to pay for the specified element.
# Deactivates the wisps that are spent. Returns an empty array if no wisps
# are available for the given element.
func pay_for_element(element: int, count: int) -> Array:
	match element:
		Constants.Element.EARTH:
			var wisps: Array = _deactivate_active_count(earth, element, count)
			if wisps.size() > 0:
				return wisps
		Constants.Element.FIRE:
			var wisps: Array = _deactivate_active_count(fire, element, count)
			if wisps.size() > 0:
				return wisps
		Constants.Element.WATER:
			var wisps: Array = _deactivate_active_count(water, element, count)
			if wisps.size() > 0:
				return wisps
		Constants.Element.WIND:
			var wisps: Array = _deactivate_active_count(wind, element, count)
			if wisps.size() > 0:
				return wisps
		Constants.Element.LIGHT:
			var elems: Array = ElementalPolarity.get_light_elements()
			var wisps: Array = _deactivate_polar_active(elems[0], elems[1], count)
			emit_signal("active_count_changed", element)
			return wisps
		Constants.Element.DARK:
			var elems: Array = ElementalPolarity.get_dark_elements()
			var wisps: Array = _deactivate_polar_active(elems[0], elems[1], count)
			emit_signal("active_count_changed", element)
			return wisps
	return []


# Called when the node enters the scene tree for the first time.
func _ready():
	_set_active_count()


# Called when creating a new node.
func _init(new_player_name: String = "") -> void:
	player_name = new_player_name
	name = "{0}WispPool".format([player_name])
	var bonded_wisps: Dictionary = WispTracker.get_bonded_wisps(player_name)
	for element_wisps in bonded_wisps.values():
		for wisp in element_wisps:
			add_new_wisp(wisp)
	_set_active_count()


# Gets the active count for each element pool.
func _set_active_count() -> void:
	# Reset count to prevent overcounting during initialization.
	_active_count[Constants.CoreElement.EARTH] = 0
	_active_count[Constants.CoreElement.FIRE] = 0
	_active_count[Constants.CoreElement.WATER] = 0
	_active_count[Constants.CoreElement.WIND] = 0
	for is_active in earth.values():
		_active_count[Constants.CoreElement.EARTH] += 1 if is_active else 0
	for is_active in fire.values():
		_active_count[Constants.CoreElement.FIRE] += 1 if is_active else 0
	for is_active in water.values():
		_active_count[Constants.CoreElement.WATER] += 1 if is_active else 0
	for is_active in wind.values():
		_active_count[Constants.CoreElement.WIND] += 1 if is_active else 0


# Helper function for pay_for_element. Deactivates a number of active wisps in the
# given category. Returns the keys of said wisp, if any. Returns an empty array
# if none are found.
func _deactivate_active_count(wisps: Dictionary, element: int, count: int) -> Array:
	var count_tracker: int = 0
	var deactivated_wisps: Array = []
	for wisp in wisps.keys():
		if count_tracker < count and wisps[wisp]:
			wisps[wisp] = false
			_active_count[element] -= 1
			count_tracker += 1
			deactivated_wisps.append(wisp)
	if count_tracker > 0:
		emit_signal("active_count_changed", element)
	return deactivated_wisps


# Helper function for pay_for_element. Deactivates the first active wisps for the
# relevant polar elements. Return an empty array if not enough elements are
# active.
func _deactivate_polar_active(elem_1: int, elem_2: int, count: int) -> Array:
	var wisps: Array = []
	if _active_count[elem_1] == 0 or _active_count[elem_2] == 0:
		return wisps
	var elem_1_wisps: Array = _deactivate_active_count(
			_get_element_tracker(elem_1),
			elem_1,
			count
	)
	var elem_2_wisps: Array = _deactivate_active_count(
			_get_element_tracker(elem_2),
			elem_2,
			count
	)
	wisps.append_array(elem_1_wisps)
	wisps.append_array(elem_2_wisps)
	return wisps


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
