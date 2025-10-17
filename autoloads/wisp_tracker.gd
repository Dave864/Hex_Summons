extends Node
"""
Tracks the condition of all wisps, whether they are bonded to a player, and what
state they are in. If a wisp is not listed within this class, it will not be
interacted with in game.
"""


const NO_PLAYER: String = "NONE"
const DATA: String = "data"
const ELEMENT: String = "element"
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

var _tracked_wisps: Dictionary = {
	"test_earth_1": _initialize_data("test_earth_1", EARTH, "Melee"),
	"test_earth_2": _initialize_data("test_earth_2", EARTH, "Melee"),
	"test_fire_1": _initialize_data("test_fire_1", FIRE, "Range"),
	"test_fire_2": _initialize_data("test_fire_2", FIRE, "Range"),
	"test_water_1": _initialize_data("test_water_1", WATER),
	"test_water_2": _initialize_data("test_water_2", WATER),
	"test_wind_1": _initialize_data("test_wind_1", WIND),
	"test_wind_2": _initialize_data("test_wind_2", WIND),
}


# Gets the data for the specified wisp.
func get_data(wisp: String) -> Wisp:
	if not _is_tracked(wisp):
		return null
	return _tracked_wisps[wisp][DATA]


# Gets the element the wisp is part of. Returns -1 if the given name is not in
# any wisp pool.
func wisp_element(wisp: String) -> int:
	if not _is_tracked(wisp):
		return -1
	return _tracked_wisps[wisp][ELEMENT]


# Updates the player the wisp is bonded to. Player defaults to NO_PLAYER, which
# indicates the wisp is to be unbonded. The wisp is also set to inactive when
# NO_PLAYER is specified. Returns if the operation was successful or not, such
# as if the provided wisp is valid.
func set_bonded_player(wisp: String, player: String = NO_PLAYER) -> bool:
	if not _is_tracked(wisp):
		return false
	_tracked_wisps[wisp][BONDED_PLAYER] = player
	if player == NO_PLAYER:
		return _update_encounter_state(wisp, WispState.INACTIVE)
	return true


# Gets all the wisps that are bonded to a specified player.
func get_bonded_wisps(player: String) -> Dictionary:
	var bonded_wisps: Dictionary = {EARTH: [], FIRE: [], WATER: [], WIND: []}
	for wisp in _tracked_wisps.keys():
		if _tracked_wisps[wisp][BONDED_PLAYER] == player:
			bonded_wisps[_tracked_wisps[wisp][ELEMENT]].append(wisp)
	return bonded_wisps


# Checks if the wisp is intended to be set to a player.
func is_player_set(wisp: String) -> bool:
	return _is_in_state(wisp, WispState.PLAYER_SET)


# Checks if the wisp is in the summmon pool.
func is_summon_pool(wisp: String) -> bool:
	return _is_in_state(wisp, WispState.SUMMON_POOL)


# Checks if the wisp is in the pool for an active summon.
func is_summon_set(wisp: String) -> bool:
	return _is_in_state(wisp, WispState.SUMMON_SET)


# Checks if the wisp is inactive.
func is_inactive(wisp: String) -> bool:
	return _is_in_state(wisp, WispState.INACTIVE)


# Updates the state of wisps to indicate it is in the bonded player's pool.
# Returns if the operation was successful or not, such as if the provided wisp
# is valid.
func set_state_to_player(wisps: Array) -> bool:
	var success: bool = true
	for wisp in wisps:
		if not _update_encounter_state(wisp, WispState.PLAYER_SET):
			success = false
	return success


# Updates the state of wisps to indicate it is in the summon pool. Returns
# if the operation was successful or not, such as if the provided wisp is valid.
func set_state_to_summon_pool(wisps: Array) -> bool:
	var success: bool = true
	for wisp in wisps:
		if not _update_encounter_state(wisp, WispState.SUMMON_POOL):
			success = false
	return success


# Updates the state of wisps to indicate it is part of the active summon's
# pool. Returns if the operation was successful or not, such as if the
# provided wisp is valid.
func set_state_to_summon_set(wisps: Array) -> bool:
	var success: bool = true
	for wisp in wisps:
		if not _update_encounter_state(wisp, WispState.SUMMON_SET):
			success = false
	return success


# Updates the state of the wisp to mark it as inactive, indicating that it is
# currently unavailable for use by the party. Also clears the bonded player.
# Returns if the operation was successful or not, such as if the provided wisp
# is valid. 
func set_state_to_inactive(wisp: String) -> bool:
	return set_bonded_player(wisp)


# Loads the save data for the wisps.
func load_save_data(save_data: Dictionary) -> void:
	for wisp in save_data.keys():
		_tracked_wisps[wisp][ELEMENT] = save_data[wisp][ELEMENT]
		_tracked_wisps[wisp][BONDED_PLAYER] = save_data[wisp][BONDED_PLAYER]
		_tracked_wisps[wisp][ENCOUNTER_STATE] = save_data[wisp][ENCOUNTER_STATE]


# Gets the current state of the wisp manager for the purposes of saving the data.
func get_save_data() -> Dictionary:
	var save_data: Dictionary = {}
	for wisp in _tracked_wisps.keys():
		save_data[wisp] = {
			ELEMENT: _tracked_wisps[wisp][ELEMENT],
			BONDED_PLAYER: _tracked_wisps[wisp][BONDED_PLAYER],
			ENCOUNTER_STATE: _tracked_wisps[wisp][ENCOUNTER_STATE]
		}
	return save_data


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Initializes the data for a wisp.
func _initialize_data(
	wisp_name: String,
	element: int,
	bonded_player: String = NO_PLAYER
) -> Dictionary:
	return {
		DATA: _get_wisp_data(wisp_name, element),
		ELEMENT: element,
		BONDED_PLAYER: bonded_player,
		ENCOUNTER_STATE: WispState.INACTIVE
	}


# Checks if there is a wisp of the given name being tracked.
func _is_tracked(wisp: String) -> bool:
	if not _tracked_wisps.has(wisp):
		"No wisp named {0} is tracked".format([wisp])
		return false
	return true


# Gets the wisp data for a given name and element, returning null if there is
# no wisp with the given name and element combo.
func _get_wisp_data(wisp_name: String, element: int) -> Wisp:
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
	var wisp_data: Wisp = load(path_format.format([wisp_name]))
	if wisp_data == null:
		var elem_name: String = Constants.CoreElement.find_key(element)
		printerr("No data could be found for {0} wisp, {1}.".format([elem_name, wisp_name]))
	return wisp_data


# Updates the encounter state, returning if the operation was successful,
# such as if the provided wisp is valid.
func _update_encounter_state(wisp: String, new_state: int) -> bool:
	if not _is_tracked(wisp):
		return false
	_tracked_wisps[wisp][ENCOUNTER_STATE] = new_state
	return true


# Checks if the wisp is in the specified state.
func _is_in_state(wisp: String, wisp_state: int) -> bool:
	if not _is_tracked(wisp):
		return false
	return _tracked_wisps[wisp][ENCOUNTER_STATE] == wisp_state
