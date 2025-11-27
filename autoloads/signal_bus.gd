extends Node
## Stores all of the signals that are used to communicate between components of
## different scenes, usually between their state machines.


# Player character related signals.
## Indicates a player character has started their turn.
signal player_turn_started(character)
## Indicates that an action for a player character has been selected.
signal player_action_selected(character, action)
## Indicates that an action has been confirmed.
signal player_action_executed(character, action, targets)
## Indicates that a selected option has been canceled.
signal player_action_type_canceled()
# Enemy character related signals.
## Indicates an enemy character has started their turn.
signal enemy_turn_started(character)
# Encounter selection signals
## Indicates that the selector node needs to be active.
signal selector_required(start_index)
## Indicates that the selector is disabled, or paused.
signal selector_paused()
## Indicates that the selector node needs to display details for an action.
signal action_selector_required(action)
## Indicates that a move path needs to be created.
signal move_path_requested()
## Indicates that a move path has been created,
signal move_path_created(move_path)
# Encounter threat update signals
## Indicates that health has changed for a given target as a result of some caster.
signal health_changed(caster_id, target_id, change_value)
## Indicates that the top vertex relative to camera view has been changed.
## Used for moving the selector around the encounter map using joystick input.
signal top_vertex_changed(vertex)


func emit_player_turn_started(pc: PlayerCharacter) -> void:
	emit_signal("player_turn_started", pc)


func emit_player_action_selected(pc: PlayerCharacter, action: Action) -> void:
	emit_signal("player_action_selected", pc, action)


func emit_player_action_executed(
	pc: PlayerCharacter,
	action: Action,
	targets: Array
) -> void:
	emit_signal("player_action_executed", pc, action, targets)


func emit_player_action_type_canceled() -> void:
	emit_signal("player_action_type_canceled")


func emit_enemy_turn_started(ec: EnemyCharacter) -> void:
	emit_signal("enemy_turn_started", ec)


func emit_selector_required(start_index: int) -> void:
	emit_signal("selector_required", start_index)


func emit_selector_paused() -> void:
	emit_signal("selector_paused")


func emit_action_selector_required(action: Action) -> void:
	emit_signal("action_selector_required", action)


func emit_move_path_requested() -> void:
	emit_signal("move_path_requested")


func emit_move_path_created(move_path: PackedVector3Array) -> void:
	emit_signal("move_path_created", move_path)


func emit_health_changed(
	caster_id: int,
	target_id: int,
	change_value: float
) -> void:
	emit_signal("health_changed", caster_id, target_id, change_value)


func emit_top_vertex_changed(vertex: int) -> void:
	emit_signal("top_vertex_changed", vertex)
