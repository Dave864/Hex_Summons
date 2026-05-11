extends Node
## Stores all of the signals that are used to communicate between components of
## different scenes, usually between their state machines.


# User controlled character related signals.
## Indicates a player character has started their turn.
signal player_turn_started(character)
## Indicates the summon has started their turn.
signal summon_turn_started()
## Indicates that a player character turn has been finalized, summon or otherwise.
signal player_turn_finalized()
## Indicates that an action for a user controlled character has been selected.
signal character_action_selected(action)
## Indicates that a spawn action for a summon has been selected.
signal spawn_action_selected(summon, action)
## Indicates that an action has been confirmed.
signal character_action_executed(character, action, targets)
## Indicates that a selected option has been canceled.
signal character_action_type_canceled()
## Indicates that a player character has finished moving.
signal character_movement_finished()
# Enemy character related signals.
## Indicates an enemy character has started their turn.
signal enemy_turn_started(character)
# Encounter selection signals
## Indicates that the encounter camera has finished moving.
signal camera_target_reached()
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


## Indicates that the player character has started their turn.
func emit_player_turn_started(pc: PlayerCharacter) -> void:
	emit_signal("player_turn_started", pc)


## Indicates that a summon has started their turn.
func emit_summon_turn_started() -> void:
	emit_signal("summon_turn_started")


## Indicates that the actions for a player character's turn have been confirmed
## and finalized.
func emit_player_turn_finalized() -> void:
	emit_signal("player_turn_finalized")


## Indicates that an action for a character has been selected.
func emit_character_action_selected(action: Action) -> void:
	emit_signal("character_action_selected", action)


## Indicates that a spawn action for a summon has been selected.
func emit_spawn_action_selected(summon: String, action: Action) -> void:
	emit_signal("spawn_action_selected", summon, action)


## Indicates that an action for a character is meant to be executed against the
## targets.
func emit_character_action_executed(
	c: Character,
	action: Action,
	targets: Array
) -> void:
	emit_signal("character_action_executed", c, action, targets)


## Indicates that selection for an action type has been canceled.
func emit_character_action_type_canceled() -> void:
	emit_signal("character_action_type_canceled")


## Inidicates that a player character has finished moving.
func emit_character_movement_finished() -> void:
	emit_signal("character_movement_finished")


## Indicates that the enemy character has started their turn.
func emit_enemy_turn_started(ec: EnemyCharacter) -> void:
	emit_signal("enemy_turn_started", ec)


## Indicates that the selector is required to display the details for an action.
func emit_action_selector_required(action: Action) -> void:
	emit_signal("action_selector_required", action)


## Indicates that the encounter camera has reached its movement destination.
func emit_camera_target_reached() -> void:
	emit_signal("camera_target_reached")


## Indicates that a move path needs to be made.
func emit_move_path_requested() -> void:
	emit_signal("move_path_requested")


## Indicates that a move path has been created.
func emit_move_path_created(move_path: PackedVector3Array) -> void:
	emit_signal("move_path_created", move_path)


## Indicates that the camera should focus on a new point, moving to said point
## in a specific way.
func emit_position_camera_focus(
	position: Vector3,
	movement_type: TrackingPoint.MovementType
) -> void:
	emit_signal("position_camera_focus", position, movement_type)


## Indicates that the health for a target has changed by some amount by another
## character.
func emit_health_changed(
	caster_id: int,
	target_id: int,
	change_value: float
) -> void:
	emit_signal("health_changed", caster_id, target_id, change_value)


## Inidicates that the hex vertex considered the "top" has been changed.
func emit_top_vertex_changed(vertex: int) -> void:
	emit_signal("top_vertex_changed", vertex)
