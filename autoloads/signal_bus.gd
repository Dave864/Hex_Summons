extends Node
## Stores all of the signals that are used to communicate between components of
## different scenes, usually between their state machines.


# User controlled character related signals.
## Indicates a player character has started their turn.
signal player_turn_started(character)
## Indicates the summon has started their turn.
signal summon_turn_started()
## Indicates that an action for a user controlled character has been selected.
signal character_action_selected(action)
## Indicates that a spawn action for a summon has been selected.
signal spawn_action_selected(summon, action)
## Indicates that an action has been confirmed.
signal character_action_executed(character, action, targets)
## Indicates that a selected option has been canceled.
signal character_action_type_canceled()
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
## Indicates that a move path has been created.
signal move_path_created(move_path)
## Indicates that the encounter camera should focus on a specific position.
signal position_camera_focus(position, movement_type)
# Encounter threat update signals
## Indicates that health has changed for a given target as a result of some caster.
signal health_changed(caster_id, target_id, change_value)
## Indicates that the top vertex relative to camera view has been changed.
## Used for moving the selector around the encounter map using joystick input.
signal top_vertex_changed(vertex)


func emit_player_turn_started(pc: PlayerCharacter) -> void:
	emit_signal("player_turn_started", pc)


func emit_summon_turn_started() -> void:
	emit_signal("summon_turn_started")


func emit_character_action_selected(action: Action) -> void:
	emit_signal("character_action_selected", action)


func emit_spawn_action_selected(summon: String, action: Action) -> void:
	emit_signal("spawn_action_selected", summon, action)


func emit_character_action_executed(
	c: Character,
	action: Action,
	targets: Array
) -> void:
	emit_signal("character_action_executed", c, action, targets)


func emit_character_action_type_canceled() -> void:
	emit_signal("character_action_type_canceled")


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


func emit_position_camera_focus(
	position: Vector3,
	movement_type: TrackingPoint.MovementType
) -> void:
	emit_signal("position_camera_focus", position, movement_type)


func emit_health_changed(
	caster_id: int,
	target_id: int,
	change_value: float
) -> void:
	emit_signal("health_changed", caster_id, target_id, change_value)


func emit_top_vertex_changed(vertex: int) -> void:
	emit_signal("top_vertex_changed", vertex)
