class_name Encounter
extends Node
"""
Manages the events of an encounter.
"""


# Reference to the encounter hex_map. This is to allow for differently named
# hex map scene to be used.
export(NodePath) var hex_map_path = null

var cur_init: int = 0

onready var players: Array = PartyController.get_party_members()
onready var enemies: Array = $Enemies.get_children()
onready var selector: Selector = $Selector
onready var hex_map: HexMap = get_node(hex_map_path)
onready var ui: EncounterUI = $EncounterUI


# Move the initiative counter to the next index or reset it back to the start.
func progress_initiative() -> void:
	yield(ui.initiative_tracker.progress_initiative(), "completed")


# Gets the next character in the intiative track.
func get_next_character() -> Character:
	return ui.initiative_tracker.get_next_character()


# Gets the character currently in initiative.
func get_current_character() -> Character:
	return ui.initiative_tracker.get_current_character()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_check_for_required_parameters()
	"""
	TODO: implement logic to load the HexMap, based on some details determined
	out of scene.
	"""
	hex_map = get_node(hex_map_path)
	_connect_map_to_selector()
	
	"""
	TODO: implement logic to load the players and enemies, placing them at
	appropriate spots on the HexMap.
	"""
	
	for p in players:
		$Players.add_child(p)
		p.stats.max_cur_health()
	ui.track_party_members(players)
	
	for e in enemies:
		var ai_node: CharacterAI = e.get_node("CharacterAI")
		ai_node.connect_encounter_details(hex_map, e, players, enemies)
		ui.track_enemy(e)


# Connects all map tile "mouse_hovered" signals to the selector.
func _connect_map_to_selector() -> void:
	selector.players_ref = players
	selector.enemies_ref = enemies
	selector.hex_map = hex_map
	for mt in hex_map.get_map_tiles():
		ErrorUtil.connect_signal(
				mt,
				"mouse_hovered",
				selector,
				"_on_MapTile_mouse_hovered"
		)


# Check that all required parameters are set.
func _check_for_required_parameters() -> void:
	assert(
		hex_map_path != null,
		"Encounter has not set the path for the hex_map."
	)
	assert(players.size() > 0, "No players are present.")
	assert(enemies.size() > 0, "No enemies are present.")
	assert(
		selector != null,
		ErrorUtil.missing_required_parameter(name, selector.name)
	)
	assert(ui != null, ErrorUtil.missing_required_parameter(name, ui.name))
