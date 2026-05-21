extends Node
## Tracks the condition of all wisps, whether they are bonded to a player, and what
## state they are in.
##
## This global class keeps track of the current state of all wisps. A wisp can
## be set to bonded player, in the standby pool, set to active summon, or
## completely inactve. An inactive wisp is not bonded to a player, and is
## unable to be set to the standby pool or active summon. This class works in
## tandem with WispController to manage the reorganization of wisps. If a wisp
## is not listed within this class, it will not be interacted with in game.


const NO_PLAYER := "NONE"
const NAME := "name"
const DATA := "data"
const ELEMENT := "element"
const BONDED_PLAYER := "bonded_player"
const GAME_STATE := "game_state"

enum WispState {
	PLAYER_SET, ## The wisp is set to a player
	STANDBY_SET, ## The wisp is set to standby
	SUMMON_SET, ## The wisp is set to an active summon
	INACTIVE ## The wisp is not able to be interacted with
}

@onready var _tracked_wisps: Dictionary[String, WispDetails] = {
	"test_earth_1": _initialize_data("test_earth_1", "Player1"),
	"test_earth_2": _initialize_data("test_earth_2", "Player1"),
	"test_fire_1": _initialize_data("test_fire_1", "Player2"),
	"test_fire_2": _initialize_data("test_fire_2", "Player2"),
	"test_water_1": _initialize_data("test_water_1"),
	"test_water_2": _initialize_data("test_water_2"),
	"test_wind_1": _initialize_data("test_wind_1"),
	"test_wind_2": _initialize_data("test_wind_2"),
}


## Gets the data for the specified wisp.
func get_wisp_data(wisp: String) -> Wisp:
	if not _is_tracked(wisp):
		return null
	return _tracked_wisps[wisp].data


## Gets the number of wisps for each core element that are available for the
## party to use.
func get_usable_wisp_count() -> Dictionary[Element.Core, int]:
	var counts: Dictionary[Element.Core, int] = {
		Element.Core.EARTH: 0,
		Element.Core.FIRE: 0,
		Element.Core.WATER: 0,
		Element.Core.WIND: 0,
	}
	for wisp_details: WispDetails in _tracked_wisps.values():
		if wisp_details.game_state != WispState.INACTIVE:
			counts[wisp_details.element] += 1
	return counts


## Gets the element the wisp is part of. Returns -1 if the given name is not in
## any wisp pool.
func wisp_element(wisp: String) -> int:
	if not _is_tracked(wisp):
		return -1
	return _tracked_wisps[wisp].element


## Gets the name of the player that the wisp is currently bonded to. Returns
## "NONE" if the wisp is not bonded to any player. 
func get_bonded_player(wisp: String) -> String:
	return _tracked_wisps[wisp].bonded_player


## Updates the player the wisp is bonded to. Player defaults to NO_PLAYER, which
## indicates the wisp is to be unbonded. The wisp is also set to inactive when
## NO_PLAYER is specified. Returns if the operation was successful or not, such
## as if the provided wisp is valid.
func set_bonded_player(wisp: String, player: String = NO_PLAYER) -> bool:
	if not _is_tracked(wisp):
		return false
	_tracked_wisps[wisp].bonded_player = player
	if player == NO_PLAYER:
		return _update_encounter_state(wisp, WispState.INACTIVE)
	return true


## Gets all the wisps that are bonded to a specified player. Each array contains
## the wisp names.
func get_bonded_wisps(player: String) -> Dictionary[Element.Core, PackedStringArray]:
	var bonded_wisps: Dictionary[Element.Core, PackedStringArray] = {
		Element.Core.EARTH: [],
		Element.Core.FIRE: [],
		Element.Core.WATER: [],
		Element.Core.WIND: [],
	}
	for wisp: String in _tracked_wisps.keys():
		if _tracked_wisps[wisp].bonded_player == player:
			bonded_wisps[_tracked_wisps[wisp].element].append(wisp)
	return bonded_wisps


## Checks if the wisp is intended to be set to a player.
func is_player_set(wisp: String) -> bool:
	return _is_in_state(wisp, WispState.PLAYER_SET)


## Checks if the wisp is in the standby pool.
func is_standby_set(wisp: String) -> bool:
	return _is_in_state(wisp, WispState.STANDBY_SET)


## Checks if the wisp is in the pool for an active summon.
func is_summon_set(wisp: String) -> bool:
	return _is_in_state(wisp, WispState.SUMMON_SET)


## Checks if the wisp is inactive.
func is_inactive(wisp: String) -> bool:
	return _is_in_state(wisp, WispState.INACTIVE)


## Updates the state of wisps to indicate it is in the bonded player's pool.
## Returns if the operation was successful or not, such as if the provided wisp
## is valid.
func set_state_to_player(wisps: Array) -> bool:
	var success: bool = true
	for wisp in wisps:
		if not _update_encounter_state(wisp, WispState.PLAYER_SET):
			success = false
	return success


## Updates the state of wisps to indicate it is in the standby pool. Returns
## if the operation was successful or not, such as if the provided wisp is valid.
func set_state_to_standby_set(wisps: Array[String]) -> bool:
	var success: bool = true
	for wisp: String in wisps:
		if not _update_encounter_state(wisp, WispState.STANDBY_SET):
			success = false
	return success


## Updates the state of wisps to indicate it is part of the active summon's
## pool. Returns if the operation was successful or not, such as if the
## provided wisp is valid.
func set_state_to_summon_set(wisps: Array[String]) -> bool:
	var success: bool = true
	for wisp: String in wisps:
		if not _update_encounter_state(wisp, WispState.SUMMON_SET):
			success = false
	return success


## Updates the state of the wisp to mark it as inactive, indicating that it is
## currently unavailable for use by the party. Also clears the bonded player.
## Returns if the operation was successful or not, such as if the provided wisp
## is valid. 
func set_state_to_inactive(wisp: String) -> bool:
	return set_bonded_player(wisp)


## Loads the save data for the wisps.
func load_save_data(save_data: Dictionary[String, Variant]) -> void:
	for wisp: String in save_data.keys():
		_tracked_wisps[wisp].bonded_player = save_data[wisp][BONDED_PLAYER]
		_tracked_wisps[wisp].game_state = save_data[wisp][GAME_STATE]


## Gets the current state of the wisp manager for the purposes of saving the data.
func get_save_data() -> Dictionary[String, Variant]:
	var save_data: Dictionary[String, Variant] = {}
	for wisp: String in _tracked_wisps.keys():
		save_data[wisp] = {
			BONDED_PLAYER: _tracked_wisps[wisp].game_state,
			GAME_STATE: _tracked_wisps[wisp].game_state
		}
	return save_data


## Initializes the data for a wisp.
func _initialize_data(
	wisp_name: String,
	bonded_player: String = NO_PLAYER
) -> WispDetails:
	var initial_state := (
		WispState.INACTIVE if bonded_player == NO_PLAYER
		else WispState.PLAYER_SET
	)
	return WispDetails.new(
			_get_wisp_data(wisp_name),
			bonded_player,
			initial_state
	)


## Checks if there is a wisp of the given name being tracked.
func _is_tracked(wisp: String) -> bool:
	if not _tracked_wisps.has(wisp):
		printerr("No wisp named {0} is tracked".format([wisp]))
		return false
	return true


## Gets the wisp data for a given name and element, returning null if there is
## no wisp with the given name and element combo.
func _get_wisp_data(wisp_name: String) -> Wisp:
	var path_format := "res://wisps/{0}/{1}/{1}.tres"
	for element: String in Element.Core.keys():
		var wisp_path := path_format.format([element, wisp_name])
		if ResourceLoader.exists(wisp_path, "Wisp"):
			return load(wisp_path)
	printerr("No data could be found for wisp {0}.".format([wisp_name]))
	return null


## Updates the encounter state, returning if the operation was successful,
## such as if the provided wisp is valid.
func _update_encounter_state(wisp: String, new_state: WispState) -> bool:
	if not _is_tracked(wisp):
		return false
	_tracked_wisps[wisp].game_state = new_state
	return true


## Checks if the wisp is in the specified state.
func _is_in_state(wisp: String, wisp_state: WispState) -> bool:
	if not _is_tracked(wisp):
		return false
	return _tracked_wisps[wisp].game_state == wisp_state


## Contains details about a wisp.
class WispDetails:
	## The resource data for this wisp.
	var data: Wisp
	## The element of this wisp.
	var element: Element.Core:
		get:
			return data.element
	## The player this wisp is bonded to.
	var bonded_player: String
	## The current state of the wisp in game.
	var game_state: WispState
	
	
	## Creates a new instance of wisp details.
	func _init(
		new_data: Wisp,
		new_player: String,
		initial_state: WispState
	) -> void:
		data = new_data
		bonded_player = new_player
		game_state = initial_state
