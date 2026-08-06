@abstract
class_name EncounterSpawnAlert
extends EncounterSpawnState
## Base class for the logic of the `Alert ` state.
##
## The spawner generally stops and waits for the tracked target to either get
## too close or leave detection range. The specific behavior each type of
## EncounterSpawn has must be defined in derived classes.


## The degrees per second EncounterSpawn rotates to face a target.
const ROTATION_SPEED := 60.0

## The character that is the point of focus.
var _alert_focus: CharacterBody3D = null
## Flag that indicates that the focused is within view of EncounterSpawn.
var _focus_in_view: bool = false
## Tracks the characters that are within the alert range.
var _tracked_targets: Dictionary[int, CharacterBody3D] = {}
## The number of times the focus has been reset.
var _focus_reset_count: int = 0


## Virtual function. Called by the state machine upon changing the active state.
## The `msg` parameter is a dictionary with arbitrary data the state can use to
## initialize itself.
func enter(msg: Dictionary[Variant, Variant] = {}) -> void:
	_alert_focus = msg["AlertFocus"]
	_tracked_targets[_alert_focus.get_instance_id()] = _alert_focus
	_focus_in_view = _is_in_view(_alert_focus)
	_focus_reset_count = 0
	_start_alert_timer()


## Virtual function. Corresponds to the `_process()` callback.
func update(delta: float) -> void:
	if _check_for_reaction_trigger():
		_determine_reaction()
		return
	if _tracked_targets.is_empty():
		state_machine.transition_to(IDLE, {})
		return
	_update_focus()
	_orient_to_focus_target(delta)


## Virtual function. Called by the state machine before changing the active
## state. Use this function to clean up the state.
func exit() -> void:
	_tracked_targets.clear()


## Virtual function. To be called in the _ready function to connect signals to 
## the state. The signals connected here should not be required by other states.
func _ready_connect_signals() -> void:
	super._ready_connect_signals()
	enc_spawn.alert_range.body_entered.connect(_on_AlertRange_body_entered)
	enc_spawn.alert_range.body_exited.connect(_on_AlertRange_body_exited)


## Starts the alert timer, halving the initial time by the number of times the
## focus was reset.
func _start_alert_timer() -> void:
	enc_spawn.timer.start(params.alert_time / pow(2.0, _focus_reset_count))


## Checks if the reaction behavior should be triggered. Returns if the trigger
## is activated or not.
func _check_for_reaction_trigger() -> bool:
	if enc_spawn.timer.is_stopped():
		return true
	
	var sorted_targets: Array[CharacterBody3D] = _tracked_targets.values()
	var lambda := func sort_dist_ascending(
			c1: CharacterBody3D,
			c2: CharacterBody3D
	) -> bool:
		return _distance_squared_to_ref(c1) < _distance_squared_to_ref(c2)
	sorted_targets.sort_custom(lambda)
	
	var reaction_radius := pow(params.reaction_radius, 2.0)
	for target: CharacterBody3D in sorted_targets:
		var distance := _distance_squared_to_ref(target)
		if _is_in_view(target) and distance < reaction_radius:
			return true
		elif distance < reaction_radius / 2.0:
			return true
	return false


## Looks at all tracked characters and updates focus to the closest one,
## prioritizing those that are within view.
func _update_focus() -> void:
	_focus_in_view = _is_in_view(_alert_focus)
	var closest_dist: float = _distance_squared_to_ref(_alert_focus)
	for target: CharacterBody3D in _tracked_targets.values():
		var dist := _distance_squared_to_ref(target)
		if dist < closest_dist:
			if _focus_in_view and not _is_in_view(target):
				continue
			# If the prior focus target left the alert area while still in view,
			# _focus_in_view will be false. Want to prioritize any remaining
			# target candidates that are in view in this case.
			elif not _focus_in_view and _is_in_view(target):
				_focus_in_view = true
			_alert_focus = target
			closest_dist = dist
			_focus_reset_count += 1
			_start_alert_timer()


## Gets the squared distance of the target to the EncounterSpawn.
func _distance_squared_to_ref(target: CharacterBody3D) -> float:
	if target == null:
		return INF
	return target.global_position.distance_squared_to(spawn_global_pos)


## Checks if the target is in view of the EncounterSpawn.
func _is_in_view(target: CharacterBody3D) -> bool:
	if target == null:
		return false
	var dir := _direction_2D_to_target(target)
	return enc_spawn.sprite.facing_direction.dot(dir) > 0.0


## Gets the direction from EncounterSpawn to the target.
func _direction_2D_to_target(target: CharacterBody3D) -> Vector2:
	var dir3D := spawn_global_pos.direction_to(target.global_position)
	return Vector2(dir3D.x, dir3D.z).normalized()


## Rotates EncounterSpawn so that it is facing the current focus target.
func _orient_to_focus_target(delta: float) -> void:
	var old_dir := enc_spawn.sprite.facing_direction
	var target_dir := _direction_2D_to_target(_alert_focus)
	var angle_change := deg_to_rad(ROTATION_SPEED) * delta
	enc_spawn.sprite.facing_direction = old_dir.move_toward(
			target_dir,
			angle_change
	)


## Defines how EncounterSpawn should react when something gets too close.
@abstract func _determine_reaction() -> void


## Adds the detected body to the target tracker.
func _on_AlertRange_body_entered(body: Node3D) -> void:
	if not _state_is_active():
		return
	if body is EncounterSpawn:
		if body.type == enc_spawn.type:
			return
		body.despawned.connect(_on_EncounterSpawn_despawned)
		_tracked_targets[body.get_instance_id()] = body
	elif body is OverworldAvatar:
		_tracked_targets[body.get_instance_id()] = body


## Removes the detected body from the target tracker.
func _on_AlertRange_body_exited(body: Node3D) -> void:
	if not _state_is_active():
		return
	if _tracked_targets.has(body.get_instance_id()):
		_tracked_targets.erase(body.get_instance_id())
		if body == _alert_focus:
			_alert_focus = null
	if body is EncounterSpawn:
		if body.type == enc_spawn.type:
			return
		body.despawned.disconnect(_on_EncounterSpawn_despawned)


## Removes the despawned EncounterSpawn from the targets tracker.
func _on_EncounterSpawn_despawned(id: int) -> void:
	if _tracked_targets.has(id):
		if _tracked_targets[id] == _alert_focus:
			_alert_focus = null
		_tracked_targets[id].disconnect(
				"despawned",
				Callable(self, "_on_EncounterSpawn_despawned")
		)
		_tracked_targets.erase(id)
