class_name EncounterCameraReset
extends EncounterCameraState
## The logic for what happens when an EncounterCamera scene is in the `Reset` state.
##
## The encounter camera is repositioned so that it is back at its starting orientation.
## Goes to the 'Rotate' state when repositioning is finished.


## The original rotation of the encounter camera focus point.
var original_orientation: Vector3 = Vector3.ZERO
## The current interpolation weight.
var weight: float = 0.0


## Called by the state machine upon changing the active state. The `msg` parameter
## is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> void:
	original_orientation = enc_camera.get_focus_point_orientation()
	weight = 0.0


## Virtual function. Corresponds to the `_process()` callback.
func update(delta: float) -> void:
	weight += delta * enc_camera.reset_speed
	weight = 1.0 if weight > 1.0 else weight
	enc_camera.interpolate_camera_rotation(original_orientation, weight)
	if weight >= 1.0:
		enc_camera.set_relative_top_vertex(0)
		state_machine.transition_to(ROTATE)
