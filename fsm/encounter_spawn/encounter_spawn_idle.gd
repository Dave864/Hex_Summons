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
## The travel desitnation for EncounterSpawn. Used in `Travel` behavior.
var _travel_point := Vector3.INF
## The total squared distance traveled by EncounterSpawn in this state.
var _travel_squared_distance := -1.0
## The distance that EncounterSpawn can travel before despawning.
var _despawn_distance := 0.0
## The position of EncounterSpawn in the last frame.
var _last_frame_position := Vector3.ZERO
## Flag that indicates that the EncounterSpawn is moving.
var _moving := false


## Virtual function. Called by the state machine upon changing the active state.
## The `msg` parameter is a dictionary with arbitrary data the state can use to
## initialize itself.
func enter(_msg: Dictionary[Variant, Variant] = {}) -> void:
	_moving = false
	# Reset timer from its uses in other states.
	enc_spawn.timer.stop()
	_current_pattern = (
			BehaviorPattern.ROAM if enc_spawn.roam_area != null
			else BehaviorPattern.TRAVEL
	)
	_last_frame_position = enc_spawn.position
	if _travel_squared_distance < 0.0:
		_travel_squared_distance = 0.0
		_despawn_distance = enc_spawn.idle_despawn_distance
	match _current_pattern:
		BehaviorPattern.ROAM:
			enc_spawn.set_nav_target(enc_spawn.roam_area.get_next_point())
		BehaviorPattern.TRAVEL:
			if _travel_point.is_finite():
				enc_spawn.set_nav_target(_travel_point)
			else:
				enc_spawn.set_nav_to_travel_point()
				_travel_point = enc_spawn.nav_agent.target_position
		_:
			enc_spawn.set_nav_target(enc_spawn.global_position)


## Virtual function. Corresponds to the `_physics_process()` callback.
func physics_update(_delta: float) -> void:
	match _current_pattern:
		BehaviorPattern.ROAM:
			_roam_behavior()
		BehaviorPattern.TRAVEL:
			_travel_behavior()
		_:
			return
	if _travel_squared_distance > pow(enc_spawn.idle_despawn_distance, 2.0):
		state_machine.transition_to(DESPAWN)


## Virtual function. To be called in the _ready function to connect signals to 
## the state. The signals connected here should not be required by other states.
func _ready_connect_signals() -> void:
	enc_spawn.alert_range.body_entered.connect(_on_AlertRange_body_entered)


## Handles the roaming behavior, moving the spawner from point to point.
func _roam_behavior() -> void:
	if enc_spawn.nav_agent.is_target_reached():
		_moving = false
		enc_spawn.sprite.play_idle()
		enc_spawn.nav_agent.target_position = enc_spawn.roam_area.get_next_point()
		enc_spawn.timer.start(randf_range(0.2, 2.0))
	if not enc_spawn.timer.is_stopped():
		return
	_move_spawner()



## Handles the travel behavior, moving the spawner to the final destination.
func _travel_behavior() -> void:
	if enc_spawn.nav_agent.is_target_reached():
		_moving = false
		state_machine.transition_to(DESPAWN)
		return
	_move_spawner()


## Moves EncounterSpawn to current navigation target.
func _move_spawner() -> void:
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
