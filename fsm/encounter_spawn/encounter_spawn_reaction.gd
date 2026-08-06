@abstract
class_name EncounterSpawnReaction
extends EncounterSpawnState
## Base class for the logic of the `Reaction` state.
##
## The spawner either chases a target or runs away from a target. When chasing
## a target, the spawner can either closely track the position or charge towards
## the last position.


## The possible patterns EncounterSpawn could follow.
enum BehaviorPattern{
	CHARGE,
	PURSUE,
	FLEE,
	UNDECIDED,
}

## The degrees per second the spawner rotates when charging to follow the target.
const CHARGE_ROTATION := 15.0

## The pattern followed by EncounterSpawn.
var _current_pattern := BehaviorPattern.UNDECIDED
## The total squared distance traveled by EncounterSpawn in this state.
var _travel_squared_distance := -1.0
## The position of EncounterSpawn in the last frame.
var _last_frame_position := Vector3.ZERO
## The character that serves as the primary location reference.
var _location_ref_char: CharacterBody3D = null


## Virtual function. Called by the state machine upon changing the active state.
## The `msg` parameter is a dictionary with arbitrary data the state can use to
## initialize itself.
func enter(msg: Dictionary[Variant, Variant] = {}) -> void:
	_current_pattern = msg["pattern"]
	_location_ref_char = msg["reference_character"]
	_last_frame_position = _location_ref_char.position
	_travel_squared_distance = 0.0
	var flip := -1.0 if _current_pattern == BehaviorPattern.FLEE else 1.0
	enc_spawn.sprite.facing_direction = (
			flip *_direction_2D_to_target(_location_ref_char)
	)


## Virtual function. Corresponds to the `_physics_process()` callback.
func physics_update(delta: float) -> void:
	match _current_pattern:
		BehaviorPattern.CHARGE:
			_charge_behavior(delta)
		BehaviorPattern.PURSUE:
			_pursue_behavior()
		BehaviorPattern.FLEE:
			_flee_behavior(delta)
		_:
			return


## Virtual function. Called by the state machine before changing the active
## state. Use this function to clean up the state.
func exit() -> void:
	pass


## Virtual function. To be called in the _ready function to connect signals to 
## the state. The signals connected here should not be required by other states.
func _ready_connect_signals() -> void:
	super._ready_connect_signals()
	enc_spawn.alert_range.body_entered.connect(_on_AlertRange_body_entered)


## Gets the direction from EncounterSpawn to the target.
func _direction_2D_to_target(target: CharacterBody3D) -> Vector2:
	var dir3D := spawn_global_pos.direction_to(target.global_position)
	return Vector2(dir3D.x, dir3D.z).normalized()


## The EncounterSpawn moves towards the reference character along the original
## direction.
func _charge_behavior(delta: float) -> void:
	var charge_dir := enc_spawn.sprite.facing_direction
	var target_dir := _direction_2D_to_target(_location_ref_char)
	var angle_change := deg_to_rad(CHARGE_ROTATION) * delta
	enc_spawn.sprite.facing_direction = charge_dir.move_toward(
			target_dir,
			angle_change
	)
	enc_spawn.move_in_direction(
			params.reaction_speed,
			enc_spawn.sprite.facing_direction,
			delta
	)


## The EncounterSpawn moves to the current position of the reference character.
func _pursue_behavior() -> void:
	enc_spawn.nav_agent.target_position = _location_ref_char.global_position
	enc_spawn.move_to_navigation(params.reaction_speed)


## The EncounterSpawn moves away from the reference character.
func _flee_behavior(delta: float) -> void:
	enc_spawn.move_in_direction(
			params.reaction_speed,
			enc_spawn.sprite.facing_direction,
			delta
	)


## Checks if the target is in view of the EncounterSpawn.
func _is_in_view(target: CharacterBody3D) -> bool:
	if target == null:
		return false
	var dir := _direction_2D_to_target(target)
	return enc_spawn.sprite.facing_direction.dot(dir) > 0.0


## Checks if the target is a threat to EncounterSpawn.
@abstract func _is_threat(target: CharacterBody3D) -> bool


## Adjust the direction vector of EncounterSpawn if it is fleeing. Otherwise
## does nothing.
func _on_AlertRange_body_entered(body: Node3D) -> void:
	if (
		not _state_is_active()
		or _current_pattern != BehaviorPattern.FLEE
		or not body is CharacterBody3D
		or not _is_in_view(body)
		or not _is_threat(body)
	):
		return
	var flee_dir := enc_spawn.sprite.facing_direction
	var direction_away := (flee_dir - _direction_2D_to_target(body)).normalized()
	if direction_away.is_zero_approx():
		direction_away = -_direction_2D_to_target(body)
