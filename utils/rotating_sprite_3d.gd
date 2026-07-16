class_name RotatingSprite3D
extends AnimatedSprite3D
## A billboard 3D sprite that changes the displayed sprite to reflect the
## orientation of the sprite with respect to the current camera.


## The possible orientations that the sprite can display.
enum DisplayOrientation {
	FRONT,
	FRONT_RIGHT,
	RIGHT,
	BACK_RIGHT,
	BACK,
	BACK_LEFT,
	LEFT,
	FRONT_LEFT,
}

## The direction the sprite is facing.
var facing_direction := Vector2.RIGHT:
	set(value):
		facing_direction = value
		_determine_orientation()

## The orientation that is being displayed.
var _display_orientation: DisplayOrientation

## The current camera for the scene.
@onready var _camera: Camera3D = get_viewport().get_camera_3d()


## Sets the sprite as billboard and gets the starting orientation.
func _ready() -> void:
	billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_determine_orientation()


## Updates the orientation to account for camera adjustements.
func _process(_delta: float) -> void:
	_determine_orientation()


## Determines the orientation the display should be in.
func _determine_orientation() -> void:
	var camera_dir_transform := _camera.global_transform.basis.z * -1
	var camera_dir := Vector2(
			camera_dir_transform.x,
			camera_dir_transform.z
	).normalized()
	var dot := camera_dir.dot(facing_direction)
	var right_facing := camera_dir.angle_to(facing_direction) >= 0.0
	if dot >= 0.75:
		_display_orientation = DisplayOrientation.BACK
	elif dot < 0.75 and dot > 0.25:
		_display_orientation = (
				DisplayOrientation.BACK_RIGHT if right_facing
				else DisplayOrientation.BACK_LEFT
		)
	elif dot <= 0.25 and dot >= -0.25:
		_display_orientation = (
				DisplayOrientation.RIGHT if right_facing
				else DisplayOrientation.LEFT
		)
	elif dot < -0.25 and dot > 0.75:
		_display_orientation = (
				DisplayOrientation.FRONT_RIGHT if right_facing
				else DisplayOrientation.FRONT_LEFT
		)
	else:
		_display_orientation = DisplayOrientation.FRONT
