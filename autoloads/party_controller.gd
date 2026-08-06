extends Node
## Global node that manages the details of player characters.
##
## handles the party status of all possible player characters. Also tracks
## their classes and other relevant details (inventory, etc.).


const CLASS_DATA_PATH: String = (
	"res://character/player_classes/{0}/stat_data/class_data.tres"
)
const NAME: String = "name"
const CLASS: String = "class"
const IN_PARTY: String = "in_party"
const WISP_POOL: String = "wisp_pool"

@onready var base_player_node: PackedScene = preload(
		Constants.PLAYER_FOLDER + "PlayerCharacter/PlayerCharacter.tscn"
)
@onready var party_details: Dictionary[String, PlayerDetails] = {
	"Player1": _initialize_details("Player1", "TestMeleeClass", true),
	"Player2": _initialize_details("Player2", "TestRangeClass", true),
	"Player3": _initialize_details("Player3", "TestClass", false),
	"Player4": _initialize_details("Player4", "TestClass", false),
}


## Called when the node enters the scene tree for the first time.
func _ready():
	await WispTracker.ready
	for player in party_details.keys():
		var player_name: String = party_details[player][NAME]
		var wisp_pool: PlayerWispPool = PlayerWispPool.new(player_name)
		party_details[player][WISP_POOL] = wisp_pool
		add_child(wisp_pool)


## Gets the keys of all player characters that are currently active in the
## party.
func get_active_player_names() -> Array[String]:
	var party_members: Array[String] = []
	for player: String in party_details.keys():
		if party_details[player][IN_PARTY]:
			party_members.append(player)
	return party_members


## Gets details of all characters that are currently in the party.
func get_active_party_data() -> Dictionary[String, PlayerDetails]:
	var party: Dictionary[String, PlayerDetails] = {}
	for player: String in get_active_player_names():
		party[player] = party_details[player]
	return party


## Changes the class of the specified player.
func change_class(player: String, new_class: String) -> void:
	var class_path: String = CLASS_DATA_PATH.format([new_class])
	var class_data: PlayerClassData = load(class_path)
	party_details[player][CLASS] = class_data


## Loads the save data for the party.
func load_save_data(save_data: Dictionary[String, Variant]) -> void:
	for player: String in save_data.keys():
		party_details[player][NAME] = save_data[NAME]
		party_details[player][IN_PARTY] = save_data[IN_PARTY]
		var class_path: String = CLASS_DATA_PATH.format([save_data[CLASS]])
		var class_data: PlayerClassData = load(class_path)
		party_details[player][CLASS] = class_data


## Gets the current state of the party for the purposes of saving the data.
func get_save_data() -> Dictionary[String, Dictionary]:
	var save_data: Dictionary[String, Dictionary] = {}
	for player: String in party_details.keys():
		save_data[player] = {
			NAME: party_details[player][NAME],
			CLASS: party_details[player][CLASS].name,
			IN_PARTY: party_details[player][IN_PARTY],
		}
	return save_data


## Populates the party parameters with initial details.
func _initialize_details(
	player_name: String,
	p_class: String,
	in_party: bool
) -> PlayerDetails:
	var class_path: String = CLASS_DATA_PATH.format([p_class])
	var class_data: PlayerClassData = load(class_path)
	# WispPool Will be set in the _ready function as waiting for WispTracker to
	# be ready in this function causes the data to not populate.
	return PlayerDetails.new(player_name, class_data, in_party, null)


## Describes the details of a specific player character.
class PlayerDetails:
	## The character's name.
	var name: String
	## The details of their current class.
	var class_data: PlayerClassData
	## Whether this character is in the party or not.
	var in_party: bool
	## The pool of wisps this player has.
	var wisp_pool: PlayerWispPool
	
	
	## Initializes this class object with the specified data.
	func _init(
		new_name: String,
		new_class: PlayerClassData,
		party_status: bool,
		initial_pool: PlayerWispPool
	) -> void:
		name = new_name
		class_data = new_class
		in_party = party_status
		wisp_pool = initial_pool
