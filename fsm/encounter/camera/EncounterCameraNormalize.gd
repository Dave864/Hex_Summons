extends EncounterCameraState
"""
The logic for what happens when an EncounterCamera scene is in the `Normalize` state.
The encounter camera is moved around a rotation point to a target orientation.
Moves to the `Pan` state when finished.
"""


# The original rotation of the encounter camera focus point.
var original_orientation: Vector3 = Vector3.ZERO
# The target rotation the focus point will rotate to.
var target_orientation: Vector3 = Vector3.ZERO
# The current interpolation weight.
var weight: float = 0.0


# Called by the state machine upon changing the active state. The `msg` parameter
# is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> void:
	original_orientation = enc_camera.get_focus_point_orientation()
	target_orientation = original_orientation
	target_orientation.y = enc_camera.get_closest_vertex_radian()
	weight = 0.0


# Virtual function. Corresponds to the `_process()` callback.
func update(delta: float) -> void:
	weight += delta * enc_camera.reset_speed
	weight = 1.0 if weight > 1.0 else weight
	enc_camera.interpolate_camera_rotation(
			original_orientation,
			weight,
			target_orientation
	)
	if weight >= 1.0:
		state_machine.transition_to(PAN)


# Called by the state machine before changing the active state.
# Use this function to clean up the state.
func exit() -> void:
	pass
