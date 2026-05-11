class_name PlayerWispPool
extends WispPool
## Tracks the wisp states for a Player character.


const NONE: String = ""

var player_name: String = ""
# Tracks which wisps are "active", i.e. which wisps are available to be used
# for actions.
var earth: Dictionary[String, bool] = {}
var fire: Dictionary[String, bool] = {}
var water: Dictionary[String, bool] = {}
var wind: Dictionary[String, bool] = {}


## Called when the node enters the scene tree for the first time.
func _ready():
	_set_active_count()


## Called when creating a new node.
func _init(new_player_name: String = "") -> void:
	player_name = new_player_name
	name = "{0}WispPool".format([player_name])
	var bonded_wisps: Dictionary[Element.Core, Array] = (
		WispTracker.get_bonded_wisps(player_name)
	)
	# Unable to set contents type for element_wisps as Godot v4.5 does not allow
	# for nested type collections. Setting contents type here results in an error.
	for element_wisps: Array in bonded_wisps.values():
		for wisp: String in element_wisps:
			add_new_wisp(wisp)
	_set_active_count()


## Adds wisp to the appropriate pool. Updates WispTracker.
func add_new_wisp(wisp: String) -> void:
	var element: int = WispTracker.wisp_element(wisp)
	match element:
		Element.Core.EARTH:
			earth[wisp] = false
		Element.Core.FIRE:
			fire[wisp] = false
		Element.Core.WATER:
			water[wisp] = false
		Element.Core.WIND:
			wind[wisp] = false
		_:
			printerr("Wisp {0} is not of valid element.".format([wisp]))
			return
	WispTracker.set_bonded_player(wisp, player_name)
	if WispTracker.is_player_set(wisp):
		set_active(wisp)


## Removes the wisp from the pool. Updates WispTracker.
func remove_wisp(wisp: String) -> void:
	if earth.has(wisp):
		if earth[wisp]:
			_active_count[Element.Core.EARTH] -= 1
		earth.erase(wisp)
	elif fire.has(wisp):
		if fire[wisp]:
			_active_count[Element.Core.FIRE] -= 1
		fire.erase(wisp)
	elif water.has(wisp):
		if water[wisp]:
			_active_count[Element.Core.WATER] -= 1
		water.erase(wisp)
	elif wind.has(wisp):
		if wind[wisp]:
			_active_count[Element.Core.WIND] -= 1
		wind.erase(wisp)
	else:
		return
	WispTracker.set_bonded_player(wisp)


## Updates the state of the specified wisp to "active". Does nothing if the wisp
## is not part of the pool.
func set_active(wisp: String) -> void:
	var element: Element.Core
	if earth.has(wisp):
		element = Element.Core.EARTH
		earth[wisp] = true
	elif fire.has(wisp):
		element = Element.Core.FIRE
		fire[wisp] = true
	elif water.has(wisp):
		element = Element.Core.WATER
		water[wisp] = true
	elif wind.has(wisp):
		element = Element.Core.WIND
		wind[wisp] = true
	else:
		return
	_active_count[element] += 1
	emit_signal("active_count_changed", element)


## Gets the keys for the wisps that are used to pay for the specified element.
## Deactivates the wisps that are spent. Returns an empty array if no wisps
## are available for the given element.
func pay_for_element(element: Element.Type, count: int) -> Array[String]:
	match element:
		Element.Type.EARTH:
			var wisps: Array[String] = _deactivate_active_count(
					earth,
					element,
					count
			)
			if wisps.size() > 0:
				return wisps
		Element.Type.FIRE:
			var wisps: Array[String] = _deactivate_active_count(
					fire,
					element,
					count
			)
			if wisps.size() > 0:
				return wisps
		Element.Type.WATER:
			var wisps: Array[String] = _deactivate_active_count(
					water,
					element,
					count
			)
			if wisps.size() > 0:
				return wisps
		Element.Type.WIND:
			var wisps: Array[String] = _deactivate_active_count(
					wind,
					element,
					count
			)
			if wisps.size() > 0:
				return wisps
		Element.Type.LIGHT:
			var elems: Array[Element.Core] = (
				ElementalAlignment.get_light_elements()
			)
			var wisps: Array[String] = _deactivate_polar_active(
					elems[0] as Element.Type,
					elems[1] as Element.Type,
					count
			)
			emit_signal("active_count_changed", element)
			return wisps
		Element.Type.DARK:
			var elems: Array[Element.Core] = (
				ElementalAlignment.get_dark_elements()
			)
			var wisps: Array[String] = _deactivate_polar_active(
					elems[0] as Element.Type,
					elems[1] as Element.Type,
					count
			)
			emit_signal("active_count_changed", element)
			return wisps
	return []


## Gets the active count for each element pool.
func _set_active_count() -> void:
	# Reset count to prevent overcounting during initialization.
	_active_count[Element.Core.EARTH] = 0
	_active_count[Element.Core.FIRE] = 0
	_active_count[Element.Core.WATER] = 0
	_active_count[Element.Core.WIND] = 0
	for is_active: bool in earth.values():
		_active_count[Element.Core.EARTH] += 1 if is_active else 0
	for is_active: bool in fire.values():
		_active_count[Element.Core.FIRE] += 1 if is_active else 0
	for is_active: bool in water.values():
		_active_count[Element.Core.WATER] += 1 if is_active else 0
	for is_active: bool in wind.values():
		_active_count[Element.Core.WIND] += 1 if is_active else 0


## Helper function for pay_for_element. Deactivates a number of active wisps in the
## given category. Returns the keys of said wisp, if any. Returns an empty array
## if none are found.
func _deactivate_active_count(
	wisps: Dictionary[String, bool],
	element: Element.Type,
	count: int
) -> Array[String]:
	var count_tracker: int = 0
	var deactivated_wisps: Array[String] = []
	for wisp: String in wisps.keys():
		if count_tracker < count and wisps[wisp]:
			wisps[wisp] = false
			_active_count[element] -= 1
			count_tracker += 1
			deactivated_wisps.append(wisp)
	if count_tracker > 0:
		emit_signal("active_count_changed", element)
	return deactivated_wisps


## Helper function for pay_for_element. Deactivates the first active wisps for the
## relevant polar elements. Return an empty array if not enough elements are
## active.
func _deactivate_polar_active(
	elem_1: Element.Type,
	elem_2: Element.Type,
	count: int
) -> Array[String]:
	var wisps: Array[String] = []
	if _active_count[elem_1] == 0 or _active_count[elem_2] == 0:
		return wisps
	var elem_1_wisps: Array[String] = _deactivate_active_count(
			_get_element_tracker(elem_1),
			elem_1,
			count
	)
	var elem_2_wisps: Array[String] = _deactivate_active_count(
			_get_element_tracker(elem_2),
			elem_2,
			count
	)
	wisps.append_array(elem_1_wisps)
	wisps.append_array(elem_2_wisps)
	return wisps


## Gets the tracker Dictionary for the given element. Returns an empty Dictionary
## if no corresponding tracker is found.
func _get_element_tracker(element: int) -> Dictionary[String, bool]:
	match element:
		Element.Core.EARTH:
			return earth
		Element.Core.FIRE:
			return fire
		Element.Core.WATER:
			return water
		Element.Core.WIND:
			return wind
	return {}
