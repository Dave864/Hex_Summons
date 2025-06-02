extends Node
"""
Stores all of the signals that are used to communicate between components of
different scenes, usually between their state machines.
"""


# Player character related signals.
signal player_turn_started(character)
signal player_turn_ended(character)
signal player_action_selected(action)
signal player_action_type_canceled()
# Enemy character related signals.
signal enemy_turn_started(character)
signal enemy_turn_ended(character)
signal enemy_actions_required()
signal enemy_actions_confirmed(action_chain)
# Encounter selection signals
signal selector_required()
signal action_selector_required(action)
signal move_tile_selected(map_tile)


func emit_player_turn_started(character: PlayerCharacter) -> void:
	emit_signal("player_turn_started", character)


func emit_player_turn_ended(character: PlayerCharacter) -> void:
	emit_signal("player_turn_ended", character)


func emit_player_action_selected(action: Action) -> void:
	emit_signal("player_action_selected", action)


func emit_player_action_type_canceled() -> void:
	emit_signal("player_action_type_canceled")


func emit_enemy_turn_started(character: EnemyCharacter) -> void:
	emit_signal("enemy_turn_started", character)


func emit_enemy_turn_ended(character: EnemyCharacter) -> void:
	emit_signal("enemy_turn_ended", character)


func emit_enemy_actions_required() -> void:
	emit_signal("enemy_actions_required")


func emit_enemy_actions_confirmed(action_chain: Array) -> void:
	emit_signal("enemy_actions_confirmed", action_chain)


func emit_selector_required() -> void:
	emit_signal("selector_required")


func emit_action_selector_required(action: Action) -> void:
	emit_signal("action_selector_required", action)


func emit_move_tile_selected(map_tile: MapTile) -> void:
	emit_signal("move_tile_selected", map_tile)
