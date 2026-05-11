class_name EncounterCameraNormalize
extends EncounterCameraState
## The logic for what happens when an EncounterCamera scene is in the `Normalize`
## state.
##
## The encounter camera is moved around a rotation point to a target orientation.
## Moves to the `Rotate` state when finished.


## The original rotation of the encounter camera focus point.
var _original_orientation: Vector3 = Vector3.ZERO
## The target rotation the focus point will rotate to.
var _target_orientation: Vector3 = Vector3.ZERO
## The current interpolation weight.
var _weight: float = 0.0


## Called by the state machine upon changing the active state. The `msg` parameter
## is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> void:
	_original_orientation = enc_camera.get_focus_point_orientation()
	_target_orientation = _original_orientation
	_target_orientation.y = enc_camera.get_closest_vertex_radian()
	_weight = 0.0


## Virtual function. Corresponds to the `_process()` callback.
func update(delta: float) -> void:
	_weight += delta * enc_camera.reset_speed
	_weight = 1.0 if _weight > 1.0 else _weight
	enc_camera.interpolate_camera_rotation(
			_original_orientation,
			_weight,
			_target_orientation
	)
	if _weight >= 1.0:
		state_machine.transition_to(ROTATE)


## Called by the state machine before changing the active state.
## Use this function to clean up the state.
func exit() -> void:
	pass
