@abstract
class_name EncounterSpawnIdle
extends EncounterSpawnState
## Base class for the logic of the `Idle` state.
##
## The spawner can either roam around a point or travel to a point. Each type of
## EncounterSpawn has different criteria for entering the `Alert` state, which
## must be defined in derived classes.


## The possible patterns the EncounterSpawn could follow
enum BehaviorPattern {
	ROAM,
	TRAVEL,
	UNDECIDED,
}

## The pattern followed by EncounterSpawn.
var _current_pattern := BehaviorPattern.UNDECIDED
## The total squared distance traveled by EncounterSpawn in this state.
var _travel_squared_distance := -1.0
## The position of EncounterSpawn in the last frame.
var _last_frame_position := Vector3.ZERO
## Flag that indicates that the EncounterSpawn is moving.
var _moving := false


## Virtual function. Called by the state machine upon changing the active state.
## The `msg` parameter is a dictionary with arbitrary data the state can use to
## initialize itself.
func enter(_msg: Dictionary[Variant, Variant] = {}) -> void:
	_moving = false
	_current_pattern = (
			BehaviorPattern.ROAM if enc_spawn.roam_area != null
			else BehaviorPattern.TRAVEL
	)
	_last_frame_position = enc_spawn.position
	if _travel_squared_distance < 0.0:
		_travel_squared_distance = 0.0
	if _current_pattern == BehaviorPattern.ROAM:
		enc_spawn.nav_agent.target_position = enc_spawn.roam_area.get_next_point()


## Virtual function. Corresponds to the `_process()` callback.
func update(_delta: float) -> void:
	pass


## Virtual function. Corresponds to the `_physics_process()` callback.
func physics_update(_delta: float) -> void:
	match _current_pattern:
		BehaviorPattern.ROAM:
			_roam_behavior()
		BehaviorPattern.TRAVEL:
			pass
		_:
			return
	if _travel_squared_distance > pow(enc_spawn.idle_despawn_distance, 2.0):
		state_machine.transition_to(DESPAWN)


## Virtual function. Called by the state machine before changing the active
## state. Use this function to clean up the state.
func exit() -> void:
	pass


## Virtual function. To be called in the _ready function to connect signals to 
## the state. The signals connected here should not be required by other states.
func _ready_connect_signals() -> void:
	enc_spawn.alert_range.connect(
			"body_entered",
			Callable(self, "_on_AlertRange_body_entered")
	)


## Handles the roaming behavior, moving the spawner from point to point.
func _roam_behavior() -> void:
	if enc_spawn.nav_agent.is_target_reached():
		_moving = false
		enc_spawn.sprite.play_idle()
		enc_spawn.nav_agent.target_position = enc_spawn.roam_area.get_next_point()
		enc_spawn.timer.start(randf_range(0.2, 2.0))
	if not enc_spawn.timer.is_stopped():
		return
	if not _moving:
		enc_spawn.sprite.play_movement()
	_moving = true
	enc_spawn.move_spawner(enc_spawn.idle_speed)
	_travel_squared_distance += enc_spawn.position.distance_squared_to(
			_last_frame_position
	)
	_last_frame_position = enc_spawn.position


## Triggers a transition to the `Alert` state when a relevant body enters the
## alert area.
func _on_AlertRange_body_entered(body: Node3D) -> void:
	if not _state_is_active():
		return
	if body is OverworldAvatar:
		state_machine.transition_to(ALERT, {"AlertFocus": body})
	if body is EncounterSpawn:
		_process_encounter_spawn(body)


## The behavior for determining what should happen when another EncounterSpawn
## is detected.
@abstract func _process_encounter_spawn(spawn: EncounterSpawn) -> void
