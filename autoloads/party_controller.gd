extends Node
"""
Manages the party status of player characters, as well as their classes and other
relevant details (inventory, etc.).
"""


const CLASS_DATA_PATH: String = "res://character/player_classes/{0}/stat_data/class_data.tres"
const NAME: String = "name"
const CLASS: String = "class"
const IN_PARTY: String = "in_party"
const WISP_POOL: String = "wisp_pool"
const NODE: String = "node"

onready var base_player_node: PackedScene = preload(
		"res://character/player_characters/PlayerCharacter/PlayerCharacter.tscn"
)
onready var party_details: Dictionary = {
	"Player1": _initialize_details("Melee", "TestMeleeClass", true),
	"Player2": _initialize_details("Range", "TestRangeClass", true),
	"Player3": _initialize_details("Player3", "TestClass", false),
	"Player4": _initialize_details("Player4", "TestClass", false),
}


# Gets all characters that are currently in the party.
func get_party_members() -> Array:
	var party: Array = []
	for player in party_details.keys():
		if party_details[player][IN_PARTY]:
			party.append(party_details[player][NODE])
	return party


# Changes the class of the specified player.
func change_class(player: String, new_class: String) -> void:
	var class_path: String = CLASS_DATA_PATH.format([new_class])
	var class_data: PlayerClassData = load(class_path)
	party_details[player][CLASS] = class_data


# Loads the save data for the party.
func load_save_data(save_data: Dictionary) -> void:
	for player in save_data.keys():
		party_details[player][NAME] = save_data[NAME]
		party_details[player][IN_PARTY] = save_data[IN_PARTY]
		var class_path: String = CLASS_DATA_PATH.format([save_data[CLASS]])
		var class_data: PlayerClassData = load(class_path)
		party_details[player][CLASS] = class_data


# Gets the current state of the party for the purposes of saving the data.
func get_save_data() -> Dictionary:
	var save_data: Dictionary = {}
	for player in party_details.keys():
		save_data[player] = {
			NAME: party_details[player][NAME],
			CLASS: party_details[player][CLASS].name,
			IN_PARTY: party_details[player][IN_PARTY],
		}
	return save_data


# Called when the node enters the scene tree for the first time.
func _ready():
	for player in party_details.keys():
		var class_path: String = CLASS_DATA_PATH.format([party_details[player][CLASS]])
		var class_data: PlayerClassData = load(class_path)
		var class_node: PlayerClass = PlayerClass.new(class_data)
		add_child(class_node)


# Populates the party parameters with initial details.
func _initialize_details(name: String, p_class: String, in_party: bool) -> Dictionary:
	yield(WispTracker, "ready")
	var wisp_pool: PlayerWispPool = PlayerWispPool.new(name)
	var class_path: String = CLASS_DATA_PATH.format([p_class])
	var class_data: PlayerClassData = load(class_path)
	return {
		NAME: name,
		CLASS: class_data,
		IN_PARTY: in_party,
		WISP_POOL: wisp_pool
	}
