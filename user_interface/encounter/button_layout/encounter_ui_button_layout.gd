class_name EncounterUIButtonLayout
extends EncounterUI
## Manages the various UI elements of an Encounter scene. Uses a button focused
## layout.
##
## EncounterUI handles the overall management of the various UI nodes used
## during an encounter. This scene also provides a convenient access point for
## said UI nodes. The nodes are the InitiativeTracker, the SummonPool,
## PlayerStats, an PlayerOptionButtons for movement, techniques, summons, items,
## and end.


## The maximumum number of players that can be in an encounter.
const MAX_PARTY_SIZE: int = 4
## The width of the PartyStats container node.
const PARTY_WIDTH: int = 128
## The height used for the PartyStats container node when not displaying the
## maximum party count.
const PART_PARTY_HEIGHT: int = 168
## The height used for the PartyStats container node when displaying the
## maximum party count.
const FULL_PARTY_HEIGHT: int = 224

# TODO: Currently loading CharacterSummary scene to visualize the hp values
# of enemy characters
var _character_summary: PackedScene = preload(
	"res://user_interface/encounter/button_layout/test_labels/" \
	+ "CharacterSummary/CharacterSummary.tscn"
)

## The display for the active player character.
@onready var active_character_ui: UserCharacterStatsUI = $ActiveCharacterStats
@onready var enemy_stats: VBoxContainer = $EnemyStats
@onready var options_menu: PlayerOptionsButtonLayout = $PlayerOptionsButtonLayout


## Sets the reference to the player options menu node.
func _ready() -> void:
	_player_options_menu = $PlayerOptionsButtonLayout


## Updates the active player being focused on.
func set_focused_character(new_player: PlayerCharacter) -> void:
	_show_focused_character_in_party()
	# Hide the party stats of the new focused player as they will be represented
	# by the ActivePlayerStats node.
	_party_stat_map[new_player.get_instance_id()].hide()
	_focused_character = new_player
	_summon_manager.summoner = _focused_character
	options_menu.clear_all_options()
	options_menu.populate_technique_options(_focused_character.get_techniques())
	options_menu.populate_spell_options(_focused_character.get_spells())
	options_menu.populate_summon_options(_summon_manager)
	options_menu.populate_item_options([])
	options_menu.set_focus_neighbors()
	# Disconnect the health_changed signal from the previous focused player
	# to ensure that the ActivePlayerStats node is only affected by the changes
	# applied to the health of the new focused player.
	_disconnect_focus_player_health_changed()
	active_character_ui.set_player_stats(_focused_character)
	active_character_ui.show()


## Updates the focused character to reflect the summon's details.
func set_summon_as_focus() -> void:
	_show_focused_character_in_party()
	# Hide the party stats of the summoner as they will be represented
	# by the ActivePlayerStats node.
	_party_stat_map[_summon_manager.summoner.get_instance_id()].hide()
	_focused_character = _summon_manager
	options_menu.clear_all_options()
	options_menu.populate_spell_options(_summon_manager.turn_actions)
	options_menu.set_focus_neighbors()
	# Disconnect the health_changed signal from the previous focused player
	# to ensure that the ActivePlayerStats node is only affected by the changes
	# applied to the health of the new focused player.
	_disconnect_focus_player_health_changed()
	active_character_ui.set_summon_stats(_summon_manager)
	active_character_ui.show()


## Virutal function. Displays or hides the player options menu.
func display_player_menu(display: bool) -> void:
	super.display_player_menu(display)
	if not display:
		_hide_active_stats()


## Initializes the party character details in the UI.
func track_party_members(players: Array[Character]) -> void:
	var p_count: int = int(min(players.size(), MAX_PARTY_SIZE))
	var height: int = (
			FULL_PARTY_HEIGHT if p_count == MAX_PARTY_SIZE
			else PART_PARTY_HEIGHT
	)
	_party_stats_container.set_deferred("size", Vector2(PARTY_WIDTH, height))
	for i: int in p_count:
		var player_stats: UserCharacterStatsUI = _party_stats_container.get_child(i)
		var player: PlayerCharacter = players[i] as PlayerCharacter
		_party_stat_map[player.get_instance_id()] = player_stats
		player_stats.set_player_stats(player)
		player_stats.show()


## Adds the enemy character details to the UI.
## TODO: This is to allow for CharacterSummary nodes to be used for testing
## purposes.
func track_enemy(e: EnemyCharacter) -> void:
	var e_label: CharacterSummary = _character_summary.instantiate()
	e_label.set_character_name(e.name)
	e_label.set_hp(
			e.stats.get_stat(Stat.Type.CUR_HEALTH),
			e.stats.get_stat(Stat.Type.CUR_HEALTH)
	)
	e_label.set_enemy_wisp_count()
	e_label.set_text_alignment(HORIZONTAL_ALIGNMENT_RIGHT)
	e.stats.connect(
			"health_changed",
			Callable(e_label, "_on_Character_hp_changed")
	)
	enemy_stats.add_child(e_label)


## Hides the active player stats and reveals the relevant party summary for the
## "active" character.
func _hide_active_stats() -> void:
	active_character_ui.hide()
	if _focused_character != null:
		_party_stats_container.size.y = (
				FULL_PARTY_HEIGHT if _party_stat_map.size() == MAX_PARTY_SIZE
				else PART_PARTY_HEIGHT
		)
		var character_id: int
		if _focused_character == _summon_manager and _summon_manager.is_active():
			character_id = _summon_manager.summoner.get_instance_id()
		else:
			character_id = _focused_character.get_instance_id()
		_party_stat_map[character_id].show()


## Helper function for set_focused_character and set_summon_as_focus. Reveals the
## focused player's party stats UI node.
func _show_focused_character_in_party() -> void:
	# Not all members of the party are being displayed in the PartyStats
	# container, so the partial height should be used to keep the UI display
	# from being too spread out.
	_party_stats_container.size.y = PART_PARTY_HEIGHT
	# Reveal the party stats of focused character as their details in the
	# ActivePlayerStats node will be overridden.
	if _focused_character != null:
		var character_id: int
		if _focused_character == _summon_manager and _summon_manager.is_active():
			character_id = _summon_manager.summoner.get_instance_id()
		else:
			character_id = _focused_character.get_instance_id()
		_party_stat_map[character_id].show()


## Disconnects the focused character from the ActiveCharacterStats node.
func _disconnect_focus_player_health_changed() -> void:
	var character_connected: bool = (
			_focused_character != null 
			and _focused_character.stats.is_connected(
				"health_changed",
				Callable(active_character_ui, "_on_Character_hp_changed")
			)
	)
	if character_connected:
		_focused_character.stats.disconnect(
				"health_changed",
				Callable(active_character_ui, "_on_Character_hp_changed")
		)
