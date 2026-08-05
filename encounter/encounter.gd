class_name Encounter
extends Node
## Manages the events of an encounter.


## The path to the default map.
const DEFAULT_MAP_PATH := "res://hex_map/HexMap.tscn"
## The path to the default enemy.
const DEFAULT_ENEMY_PATH := (
	"res://character/enemy_characters/EnemyCharacter/EnemyCharacter.tscn"
)

## Reference to the UI elements for the encounter.
@export var ui: EncounterUI = null

## Reference to the encounter hex_map. This is to allow for differently named
## hex map scene to be used.
var hex_map: HexMap = null
## The player characters active in the encounter.
var players: Array[Character] = []
## List of enemy characters active in the encounter.
var enemies: Array[Character] = []

## The scene used to create player characters from out of encounter data.
var _player_template: PackedScene = preload(
		"res://character/player_characters/" + \
		"PlayerCharacter/PlayerCharacter.tscn"
)

## Node that handles player character summons.
@onready var summon: Summon = $Summon
## Reference to the selection tracker node; used to highlight and select map
## tiles.
@onready var selection_tracker: SelectionTracker = $SelectionTracker
## Reference to the camera.
@onready var camera: EncounterCamera = $EncounterCamera


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_check_for_required_parameters()
	_load_map()
	_connect_map_to_selector()
	
	ui.show()
	ui.set_summon(summon)
	_load_players()
	_load_enemies()


## Calls the InitiativeTracker to progress the initiative tracker.
func progress_initiative() -> void:
	await ui.initiative_tracker.progress_initiative()


## Gets the next character in the intiative track.
func get_next_character() -> Character:
	return ui.initiative_tracker.get_next_character()


## Gets the character currently active in initiative.
func get_current_character() -> Character:
	return ui.initiative_tracker.get_current_character()


## Loads the map for this given encounter.
func _load_map() -> void:
	var map_path := SceneController.get_encounter_map_path()
	if map_path == "":
		map_path = DEFAULT_MAP_PATH
	hex_map = load(map_path).instantiate()
	selection_tracker.add_child(hex_map)
	selection_tracker.hex_map = hex_map


## Initializes player characters present in the encounter.
func _load_players() -> void:
	var p_index: int = 0
	var party_data: Dictionary[String, PartyController.PlayerDetails] = (
		PartyController.get_active_party_data()
	)
	var start_positions := _get_start_indices(
			hex_map.player_start_tiles_values,
			party_data.size()
	)
	for data: PartyController.PlayerDetails in party_data.values():
		var player: PlayerCharacter = _player_template.instantiate()
		player.defeated.connect(_on_Character_defeated)
		$Players.add_child(player)
		player.update_player_details(data)
		players.append(player)
		player.stats.max_cur_health()
		hex_map.place_character_at_tile(player, start_positions[p_index])
		p_index += 1
	ui.track_party_members(players)


## Initializes the enemy characters present in the encounter.
func _load_enemies() -> void:
	var enemy_load_paths := SceneController.get_encounter_enemy_paths()
	if enemy_load_paths.size() == 0:
		enemy_load_paths.append(DEFAULT_ENEMY_PATH)
	# TODO: Additional logic is needed to determine how many of each enemy option
	# should be loaded. For now, only one of each is loaded.
	var start_positions := _get_start_indices(
			hex_map.enemy_start_tiles_values,
			enemy_load_paths.size()
	)
	if start_positions.size() == 0:
		printerr("Not enough start positions for enemies.")
		return
	for path: String in enemy_load_paths:
		var enemy: EnemyCharacter = load(path).instantiate()
		$Enemies.add_child(enemy)
		enemies.append(enemy)
	
	var e_index: int = 0
	for enemy: EnemyCharacter in enemies:
		enemy.defeated.connect(_on_Character_defeated)
		var ai_node: CharacterAI = enemy.get_node("CharacterAI")
		ai_node.connect_encounter_details(
				hex_map,
				enemy,
				players,
				enemies,
				summon
		)
		# TODO: Currently, only a specific UI layout has the ability to show
		# enemy stats.
		if ui is EncounterUIButtonLayout:
			ui.track_enemy(enemy)
		hex_map.place_character_at_tile(enemy, start_positions[e_index])
		e_index += 1


## Gets a set of random map indices from a list of options to serve as starting
## points for the specified number of characters. Returns an empty list if the
## number of characters exceeds the options.
func _get_start_indices(
	index_options: PackedInt32Array,
	character_count: int
) -> PackedInt32Array:
	var start_options: PackedInt32Array = []
	if character_count > index_options.size():
		return start_options
	start_options.resize(character_count)
	var shuffled_options := Array(index_options.duplicate())
	shuffled_options.shuffle()
	for i: int in character_count:
		start_options[i] = shuffled_options[i]
	return start_options


## Connects all map tile "mouse_hovered" signals to the selector.
func _connect_map_to_selector() -> void:
	selection_tracker.set_players_reference(players)
	selection_tracker.set_enemies_reference(enemies)
	var selector_mouse_hovered_func := Callable(
			selection_tracker.selector,
			"_on_MapTile_mouse_hovered"
	)
	for mt: MapTile in hex_map.get_map_tiles():
		mt.connect("mouse_hovered", selector_mouse_hovered_func)


## Check that all required parameters are set.
func _check_for_required_parameters() -> void:
	assert(
		selection_tracker != null,
		ErrorUtil.missing_required_parameter(name, selection_tracker.name)
	)
	assert(ui != null, ErrorUtil.missing_required_parameter(name, ui.name))


## Updates the relevant list of characters to account for the defeated character.
func _on_Character_defeated(character: Character) -> void:
	var type: Character.Type = character.get_type()
	if type == Character.Type.ENEMY:
		enemies.erase(character)
		character.queue_free() 
	else:
		# TODO: Need to add logic to disable the player character
		pass
