extends Node
"""
Tracks the condition of all wisps, whether they are set to a player, and what
state they are in. If a wisp is not listed within this class, it will not be
interacted with in game.
"""


const NO_PLAYER: String = "NONE"
const DATA: String = "data"
const BONDED_PLAYER: String = "bonded_player"
const ENCOUNTER_STATE: String = "encounter_state"
const EARTH: int = Constants.CoreElement.EARTH
const FIRE: int = Constants.CoreElement.FIRE
const WATER: int = Constants.CoreElement.WATER
const WIND: int = Constants.CoreElement.WIND

enum WispState {
	PLAYER_SET,
	SUMMON_POOL,
	SUMMON_SET,
	INACTIVE
}

var _earth: Dictionary = {
	"test_earth_1": _initialize_data("test_earth_1", EARTH),
	"test_earth_2": _initialize_data("test_earth_2", EARTH),
}
var _fire: Dictionary = {
	"test_fire_1": _initialize_data("test_fire_1", FIRE),
	"test_fire_2": _initialize_data("test_fire_2", FIRE)
}
var _water: Dictionary = {
	"test_water_1": _initialize_data("test_water_1", WATER),
	"test_water_2": _initialize_data("test_water_2", WATER),
}
var _wind: Dictionary = {
	"test_wind_1": _initialize_data("test_wind_1", WIND),
	"test_wind_2": _initialize_data("test_wind_2", WIND),
}


# Gets the data for the wisp of the specified element. Searches for the wisp
# element if none is specified.
func get_data(wisp: String, element: int = -1) -> Wisp:
	if element < 0:
		element = _wisp_element(wisp)
	elif element in Constants.CoreElement:
		printerr("Invalid element specified.")
		return null
	match element:
		EARTH:
			if _earth.has(wisp):
				return _earth[wisp][DATA]
		FIRE:
			if _fire.has(wisp):
				return _fire[wisp][DATA]
		WATER:
			if _water.has(wisp):
				return _water[wisp][DATA]
		WIND:
			if _wind.has(wisp):
				return _wind[wisp][DATA]
		_:
			printerr("Wisp {0} not in any element pool".format([wisp]))
			return null
	var elem_name: String = Constants.CoreElement.find_key(element)
	print("Wisp {0} is not in the {1} pool.".format([wisp, elem_name]))
	return null


# Updates the player the wisp is bonded to. Player defaults to NO_PLAYER, which
# indicates the wisp is to be unbonded. The wisp is also set to inactive when
# NO_PLAYER is specified. Returns if the operation was successful or not, such
# as if the provided wisp is valid.
func set_bonded_player(wisp: String, player: String = NO_PLAYER) -> bool:
	var element: int = _wisp_element(wisp)
	match element:
		Constants.CoreElement.EARTH:
			_earth[wisp][BONDED_PLAYER] = player
		Constants.CoreElement.FIRE:
			_fire[wisp][BONDED_PLAYER] = player
		Constants.CoreElement.WATER:
			_water[wisp][BONDED_PLAYER] = player
		Constants.CoreElement.WIND:
			_wind[wisp][BONDED_PLAYER] = player
		_:
			return false
	if player == NO_PLAYER:
		return _update_encounter_state(wisp, WispState.INACTIVE)
	return true


# Gets all the wisps that are bonded to a specified player.
func get_bonded_wisps(player: String) -> Dictionary:
	return {
		EARTH: _get_bonded_wisps_from_data(_earth, player),
		FIRE: _get_bonded_wisps_from_data(_fire, player),
		WATER: _get_bonded_wisps_from_data(_water, player),
		WIND: _get_bonded_wisps_from_data(_wind, player),
	}


# Updates the state of the wisp to indicate it is in the bonded player's pool.
# Returns if the operation was successful or not, such as if the provided wisp
# is valid.
func set_state_to_player(wisp: String) -> bool:
	return _update_encounter_state(wisp, WispState.PLAYER_SET)


# Updates the state of the wisp to indicate it is in the summon pool. Returns
# if the operation was successful or not, such as if the provided wisp is valid.
func set_state_to_summon_pool(wisp: String) -> bool:
	return _update_encounter_state(wisp, WispState.SUMMON_POOL)


# Updates the state of the wisp to indicate it is part of the active summon's
# pool. Returns if the operation was successful or not, such as if the
# provided wisp is valid.
func set_state_to_summon_set(wisp: String) -> bool:
	return _update_encounter_state(wisp, WispState.SUMMON_SET)


# Updates the state of the wisp to mark it as inactive, indicating that it is
# currently unavailable for use by the party. Also clears the bonded player.
# Returns if the operation was successful or not, such as if the provided wisp
# is valid. 
func set_state_to_inactive(wisp: String) -> bool:
	return set_bonded_player(wisp)


# Loads the save data for the wisps.
func load_save_data(save_data: Dictionary) -> void:
	_load_pool_save_data(_earth, save_data[EARTH])
	_load_pool_save_data(_fire, save_data[FIRE])
	_load_pool_save_data(_water, save_data[WATER])
	_load_pool_save_data(_wind, save_data[WIND])


# Gets the current state of the wisp manager for the purposes of saving the data.
func get_save_data() -> Dictionary:
	var save_data: Dictionary = {
		EARTH: _get_pool_save_data(_earth),
		FIRE: _get_pool_save_data(_fire),
		WATER: _get_pool_save_data(_water),
		WIND: _get_pool_save_data(_wind)
	}
	return save_data


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Initializes the data for a wisp.
func _initialize_data(name: String, element: int) -> Dictionary:
	return {
		DATA: _get_wisp_data(name, element),
		BONDED_PLAYER: NO_PLAYER,
		ENCOUNTER_STATE: WispState.INACTIVE
	}


# Gets the wisp data for a given name and element, returning null if there is
# no wisp with the given name and element combo.
func _get_wisp_data(name: String, element: int) -> Wisp:
	var path_format: String
	match element:
		EARTH:
			path_format = "res://wisps/earth/{0}/{0}.tres"
		FIRE:
			path_format = "res://wisps/fire/{0}/{0}.tres"
		WATER:
			path_format = "res://wisps/water/{0}/{0}.tres"
		WIND:
			path_format = "res://wisps/wind/{0}/{0}.tres"
		_:
			printerr("An invalid element was provided.")
			return null
	# Checks if the Resource at path is indeed a wisp resource.
	var wisp_data: Wisp = load(path_format.format([name]))
	if wisp_data == null:
		var elem_name: String = Constants.CoreElement.find_key(element)
		printerr("No data could be found for {0} wisp, {1}.".format([elem_name, name]))
	return wisp_data


# Gets the element the wisp is part of. Returns -1 if the given name is not in
# any wisp pool.
func _wisp_element(wisp: String) -> int:
	if _earth.has(wisp):
		return EARTH
	if _fire.has(wisp):
		return FIRE
	if _water.has(wisp):
		return WATER
	if _wind.has(wisp):
		return WIND
	return -1


# Updates the encounter state, returning if the operation was successful,
# such as if the provided wisp is valid.
func _update_encounter_state(wisp: String, new_state: int) -> bool:
	var element: int = _wisp_element(wisp)
	match element:
		EARTH:
			_earth[wisp][ENCOUNTER_STATE] = new_state
		FIRE:
			_fire[wisp][ENCOUNTER_STATE] = new_state
		WATER:
			_water[wisp][ENCOUNTER_STATE] = new_state
		WIND:
			_wind[wisp][ENCOUNTER_STATE] = new_state
		_:
			return false
	return true


# Helper function for get_bonded_wisps. Gets the wisps bonded to the specified
# player from the provided wisp pool.
func _get_bonded_wisps_from_data(wisp_data: Dictionary, player: String) -> Array:
	var bonded_wisps: Array = []
	for wisp in wisp_data.keys():
		if wisp_data[wisp][BONDED_PLAYER] == player:
			bonded_wisps.append(wisp)
	return bonded_wisps


# Helper function for load_save_data. Updates the specified wisp pool with the
# given data.
func _load_pool_save_data(wisp_pool: Dictionary, save_data: Dictionary) -> void:
	for wisp in save_data.keys():
		wisp_pool[wisp][BONDED_PLAYER] = save_data[wisp][BONDED_PLAYER]
		wisp_pool[wisp][ENCOUNTER_STATE] = save_data[wisp][ENCOUNTER_STATE]


# Helper function for get_save_data. Gets the relevant data from the specified
# wisp pool for the purposes of saving. Gets the bonded player and encounter state.
func _get_pool_save_data(wisp_pool: Dictionary) -> Dictionary:
	var save_data: Dictionary = {}
	for wisp in wisp_pool.keys():
		save_data[wisp] = {
			BONDED_PLAYER: wisp_pool[wisp][BONDED_PLAYER],
			ENCOUNTER_STATE: wisp_pool[wisp][ENCOUNTER_STATE]
		}
	return save_data
