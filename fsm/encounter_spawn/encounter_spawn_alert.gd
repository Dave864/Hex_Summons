@abstract
class_name EncounterSpawnAlert
extends EncounterSpawnState
## Base class for the logic of the `Alert ` state.
##
## The spawner generally stops and waits for the tracked target to either get
## too close or leave detection range. The specific behavior each type of
## EncounterSpawn has must be defined in derived classes.


## The character that is the point of focus.
var _alert_focus: Node3D = null
## Tracks the characters that are within the alert range.
var _tracked_targets: Dictionary[int, TargetDetails] = {}
## The current global position of the EncounterSpawn.
var _ref_position: Vector3:
	get():
		return enc_spawn.global_position


## Virtual function. Called by the state machine upon changing the active state.
## The `msg` parameter is a dictionary with arbitrary data the state can use to
## initialize itself.
func enter(msg: Dictionary[Variant, Variant] = {}) -> void:
	_alert_focus = msg["AlertFocus"]


## Virtual function. Receives events from the `_unhandled_input()` callback.
func handle_input(_event: InputEvent) -> void:
	pass


## Virtual function. Corresponds to the `_process()` callback.
func update(_delta: float) -> void:
	pass


## Virtual function. Corresponds to the `_physics_process()` callback.
func physics_update(_delta: float) -> void:
	for target: TargetDetails in _tracked_targets.values():
		target.distance = _ref_position.distance_squared_to(target.position())


## Virtual function. Called by the state machine before changing the active
## state. Use this function to clean up the state.
func exit() -> void:
	pass


## Looks at all tracked characters and updates focus to the closest one,
## prioritizing those that are within view.
func _update_focus() -> void:
	var closest_distance: float = INF
	var in_view := false
	for target: TargetDetails in _tracked_targets.values():
		pass


## Adds the detected body to the target tracker.
func _on_AlertRange_body_entered(body: Node3D) -> void:
	if body is EncounterSpawn:
		if body.type == enc_spawn.type:
			return
		body.connect(
				"despawned",
				Callable(self, "_on_EncounterSpawn_despawned")
		)
	var distance := _ref_position.distance_squared_to(body.global_position)
	var details := TargetDetails.new(body, distance)
	_tracked_targets[body.get_instance_id()] = details


## Removes the detected body from the target tracker.
func _on_AlertRange_body_exited(body: Node3D) -> void:
	if _tracked_targets.has(body.get_instance_id()):
		_tracked_targets.erase(body.get_instance_id())
	if body is EncounterSpawn:
		if body.type == enc_spawn.type:
			return
		body.disconnect(
				"despawned",
				Callable(self, "_on_EncounterSpawn_despawned")
		)


## Removes the despawned EncounterSpawn from the targets tracker.
func _on_EncounterSpawn_despawned(id: int) -> void:
	if _tracked_targets.has(id):
		_tracked_targets[id].target.disconnect(
				"despawned",
				Callable(self, "_on_EncounterSpawn_despawned")
		)
		_tracked_targets.erase(id)


## Container that tracks data for a target.
class TargetDetails:
	## The character being tracked.
	var target: CharacterBody3D
	## How far away the character is from something.
	var distance: float
	
	
	## Creates a new instance of TargetDetails object.
	func _init(target_data: CharacterBody3D, distance_data: float) -> void:
		target = target_data
		distance = distance_data
	
	
	## Gets the global position of the target.
	func position() -> Vector3:
		return target.global_position
