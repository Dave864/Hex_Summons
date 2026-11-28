class_name Tutorial
extends Encounter
## Manages the events of the tutorial encounter.
##
## The tutorial is a structured combat encounter that walks the user through
## different aspects of a combat encounter.


## Denotes the current step in the tutorial the player is at.
enum Step{
	INTRO,
	MOVEMENT,
	TECHNIQUE,
	SPELL,
	SUMMON,
	END,
}

## The path to the scuttleshrub enemy.
const ENEMY_PATH_SCUTTLESHRUB := (
		"res://character/enemy_characters/ScuttleShrub/ScuttleShrub.tscn"
)
## The path to the stumbletree enemy.
const ENEMY_PATH_STUMBLETREE := (
		"res://character/enemy_characters/StumbleTree/StumbleTree.tscn"
)

@export_group("Text Dialogue", "dialogue_")
## The dialogue introducing the basic conceit of an encounter.
@export_multiline var dialogue_intro := ""
## The dialogue explaining movement.
@export_multiline var dialogue_move := ""
## The dialogue explaining techniques.
@export_multiline var dialogue_technique := ""
## The dialogue explaining spells.
@export_multiline var dialogue_spell := ""
## The dialogue explaining summons.
@export_multiline var dialogue_summon := ""
@export_group("Objective Summary", "tooltip_objective_")
## The tooltip describing the movement objective.
@export_multiline var tooltip_objective_movement := ""
## The tooltip summarizing the technique objective.
@export_multiline var tooltip_objective_technique := ""
## The tooltip summarizong the spell objective.
@export_multiline var tooltip_objective_spell := ""
## The tooltip summarizing the summon objective.
@export_multiline var tooltip_objective_summon := ""
@export_group("Camera Tooltips", "tooltip_")
## The tooltip dialogue for gamepad camera movement.
@export_multiline var tooltip_movement_gamepad := ""
## The tooltip dialogue for keyboard & mouse camera movement.
@export_multiline var tooltip_movement_keymouse := ""
@export_group("Player Transition Areas", "transition_area_")
## The area the player must be in to start the technique tutorial.
@export var transition_area_technique: PackedInt32Array = [
	0, 1, 2, 3, 10, 11,
	12, 20, 21, 22, 30,
	31, 40, 41, 50, 51,
	60, 61, 62, 70, 71,
	72, 80, 81, 82,
]
## The area the player must be in to start the spell tutorial.
@export var transition_area_spell: PackedInt32Array = [
	25, 26, 27, 33, 34, 35, 36,
	43, 44, 45, 46, 53, 54, 55,
	56, 64, 65, 66, 74, 75
]
## The area the player must be in to start the summon tutorial.
@export var transition_area_summon: PackedInt32Array = [
	26, 27, 35, 36, 44,
	45, 46, 54, 55, 65,
]
@export_group("Spawn Areas", "spawn_area_")
## The tiles the enemies will spawn in for the technique tutorial.
@export var spawn_area_technique: PackedInt32Array = [33, 53]
## The tiles the enemies will spawn in for the spell tutorial.
@export var spawn_area_spell: PackedInt32Array = [31, 50, 62]
## The tiles the enemies will spawn in for the summon tutorial.
@export var spawn_area_summon: PackedInt32Array = [49, 38, 48, 58]

## The current step in the tutorial process.
var tutorial_step := Step.INTRO

## The dialogue panel.
@onready var dialogue_panel: PanelDialogue = $PanelDialogue
## The pause menu.
@onready var pause_menu: PauseMenu = $PauseViewport/SubViewport/PauseMenu

## Reference to the scuttleshrub enemy.
@onready var _enemy_scuttleshrub: PackedScene = preload(ENEMY_PATH_SCUTTLESHRUB)
## Reference to the stumbletree enemy.
@onready var _enemy_stumbletree: PackedScene = preload(ENEMY_PATH_STUMBLETREE)


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_check_for_required_parameters()
	hex_map = $SelectionTracker/TutorialMap
	selection_tracker.hex_map = hex_map
	_connect_map_to_selector()
	ui.show()
	ui.set_summon(summon)
	_load_players()


## Resets the initiative tracker to match current characters.
func reset_initative_tracker() -> void:
	var characters: Array[Character] = []
	characters.append_array(players.keys())
	characters.append_array(enemies)
	ui.initiative_tracker.populate_initiative(characters)


## Progresses the step the tutorial is on. Updates the instruction dialogue,
## objective text, and loading enemies that are required for the step.
func progress_step() -> void:
	set_step(tutorial_step + 1)


## Sets the step the tutorial is on, updating the instruction dialogue,
## objective text, and loading enemies that are required for the step.
func set_step(current_step: Step) -> void:
	tutorial_step = current_step
	ui.tutorial_step = current_step
	match tutorial_step:
		Step.INTRO:
			dialogue_panel.set_text(dialogue_intro)
			pause_menu.update_objective("")
			_restore_party_health()
			_place_players_intro()
		Step.MOVEMENT:
			_connect_selector_to_characters()
			var selection := (
					"the left joystick" if InputController.source_is_gamepad()
					else "the mouse"
			)
			var confirmation := (
					"" if InputController.source_is_gamepad()
					else ""
			)
			dialogue_move = dialogue_move.format([selection, confirmation])
			dialogue_panel.set_text(dialogue_move)
			pause_menu.update_objective(tooltip_objective_movement)
		Step.TECHNIQUE:
			_connect_selector_to_characters()
			dialogue_panel.set_text(dialogue_technique)
			pause_menu.update_objective(tooltip_objective_technique)
			_restore_party_health()
			_place_enemies_technique_phase()
		Step.SPELL:
			_connect_selector_to_characters()
			dialogue_panel.set_text(dialogue_spell)
			pause_menu.update_objective(tooltip_objective_spell)
			_restore_party_health()
			_place_enemies_spell_phase()
		Step.SUMMON:
			_connect_selector_to_characters()
			dialogue_panel.set_text(dialogue_summon)
			pause_menu.update_objective(tooltip_objective_summon)
			_restore_party_health()
			_place_enemies_summon_phase()


## Defines a notification area for the selection tracker based off the expected
## next step.
func set_notification_area() -> void:
	match tutorial_step:
		Step.MOVEMENT:
			selection_tracker.notification_indexes = transition_area_technique
		Step.TECHNIQUE:
			selection_tracker.notification_indexes = transition_area_spell
		Step.SPELL:
			selection_tracker.notification_indexes = transition_area_summon
		_:
			selection_tracker.notification_indexes.clear()


## Checks if all the players are within an active transition zone.
func players_in_transition_area() -> bool:
	for player: PlayerCharacter in players.keys():
		var index := player.map_coordinate.get_tile_index()
		if not selection_tracker.notification_indexes.has(index):
			return false
	return true


## Resets all party health to max.
func _restore_party_health() -> void:
	for player: PlayerCharacter in players:
		# Sets the player as active if it was defeated previously
		players[player] = true
		player.stats.max_cur_health()


## Places the players at their starting positions.
func _place_players_intro() -> void:
	for index: int in players.size():
		hex_map.place_character_at_tile(
				players.keys()[index],
				hex_map.player_start_tiles_values[index]
		)


## Places enemy characters for the technique phase.
func _place_enemies_technique_phase() -> void:
	for tile_id: int in spawn_area_technique:
		var enemy: EnemyCharacter = _enemy_scuttleshrub.instantiate()
		$Enemies.add_child(enemy)
		enemies.append(enemy)
		enemy.defeated.connect(_on_Character_defeated)
		hex_map.place_character_at_tile(enemy, tile_id)
	_connect_character_ai()
	_refresh_initiative_tracker()


## Places enemy characters for the spell phase.
func _place_enemies_spell_phase() -> void:
	for index: int in spawn_area_spell.size():
		var enemy: EnemyCharacter = _enemy_scuttleshrub.instantiate()
		$Enemies.add_child(enemy)
		enemies.append(enemy)
		enemy.defeated.connect(_on_Character_defeated)
		hex_map.place_character_at_tile(enemy, spawn_area_spell[index])
	_connect_character_ai()
	_refresh_initiative_tracker()


## Places enemy characters for the summon phase.
func _place_enemies_summon_phase() -> void:
	for index: int in spawn_area_summon.size():
		var enemy: EnemyCharacter = (
				_enemy_stumbletree.instantiate() if index == 0
				else _enemy_scuttleshrub.instantiate()
		) 
		$Enemies.add_child(enemy)
		enemies.append(enemy)
		enemy.defeated.connect(_on_Character_defeated)
		hex_map.place_character_at_tile(enemy, spawn_area_summon[index])
	_connect_character_ai()
	_refresh_initiative_tracker()


## Goes through the current enemies and connects their ai logic to the encounter
## scene.
func _connect_character_ai() -> void:
	for enemy: Node in $Enemies.get_children():
		var ai_node: CharacterAI = enemy.get_node("CharacterAI")
		ai_node.connect_encounter_details(
				hex_map,
				enemy,
				players.keys(),
				enemies,
				summon
		)


## Resets the initiative tracker to account for the current characters.
func _refresh_initiative_tracker() -> void:
	var characters: Array[Character] = players.keys()
	characters.append_array(enemies)
	ui.initiative_tracker.populate_initiative(characters)


## Initializes player characters present in the encounter.
func _load_players() -> void:
	var p_index: int = 0
	var party_data: Dictionary[String, PartyController.PlayerDetails] = (
		PartyController.get_active_party_data()
	)
	for data: PartyController.PlayerDetails in party_data.values():
		var player: PlayerCharacter = _player_template.instantiate()
		player.defeated.connect(_on_Character_defeated)
		$Players.add_child(player)
		player.update_player_details(data)
		players[player] = true
		player.stats.max_cur_health()
		hex_map.place_character_at_tile(
				player,
				hex_map.player_start_tiles_values[p_index]
		)
		p_index += 1
	ui.track_party_members(players.keys())
