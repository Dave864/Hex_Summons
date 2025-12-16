class_name Encounter
extends Node
## Manages the events of an encounter.


## Reference to the encounter hex_map. This is to allow for differently named
## hex map scene to be used.
@export var hex_map: HexMap = null

## The player characters active in the encounter.
var players: Array = []

## The scene used to create player characters from out of encounter data.
var _player_template: PackedScene = preload(
		"res://character/player_characters/" + \
		"PlayerCharacter/PlayerCharacter.tscn"
)

## List of enemy characters active in the encounter.
@onready var enemies: Array = $Enemies.get_children()
## Reference to the Selector node; used to highlight and select map tiles.
@onready var selector: Selector = $Selector
## Reference to the UI elements for the encounter.
@onready var ui: EncounterUI = $EncounterUI



## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_check_for_required_parameters()
	## TODO: implement logic to load the HexMap, based on some details determined
	## out of scene.
	_connect_map_to_selector()
	
	var p_index: int = 0
	var party_data: Dictionary[String, Dictionary] = (
		PartyController.get_active_party_data()
	)
	for data: Dictionary[String, Variant] in party_data.values():
		var player: PlayerCharacter = _player_template.instantiate()
		$Players.add_child(player)
		player.update_player_details(data)
		players.append(player)
		player.stats.max_cur_health()
		hex_map.place_character_at_tile(player, hex_map.player_start_tiles[p_index])
		p_index += 1
	ui.track_party_members(players)
	
	## TODO: implement logic to load enemies from out of scene.
	var e_index: int = 0
	for e in enemies:
		var ai_node: CharacterAI = e.get_node("CharacterAI")
		ai_node.connect_encounter_details(hex_map, e, players, enemies)
		ui.track_enemy(e)
		hex_map.place_character_at_tile(e, hex_map.enemy_start_tiles[e_index])
		e_index += 1


## Calls the InitiativeTracker to progress the initiative tracker.
func progress_initiative() -> void:
	await ui.initiative_tracker.progress_initiative()


## Gets the next character in the intiative track.
func get_next_character() -> Character:
	return ui.initiative_tracker.get_next_character()


## Gets the character currently active in initiative.
func get_current_character() -> Character:
	return ui.initiative_tracker.get_current_character()


## Connects all map tile "mouse_hovered" signals to the selector.
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


## Check that all required parameters are set.
func _check_for_required_parameters() -> void:
	assert(
		hex_map != null,
		"Encounter has not set a hex map."
	)
	assert(enemies.size() > 0, "No enemies are present.")
	assert(
		selector != null,
		ErrorUtil.missing_required_parameter(name, selector.name)
	)
	assert(ui != null, ErrorUtil.missing_required_parameter(name, ui.name))
