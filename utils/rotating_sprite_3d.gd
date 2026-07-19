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

## Indicates if the rotating sprite should align to hexagonal directions.
@export var bind_to_hex: bool = false

## The direction the sprite is facing.
var facing_direction := Vector2.RIGHT:
	set(value):
		facing_direction = value
		_determine_orientation()

## The orientation that is being displayed.
var _orientation: DisplayOrientation
## The animation group that is currently playing. The prefix for the animation
## name.
var _animation_group: String

## The current camera for the scene.
@onready var _camera: Camera3D = get_viewport().get_camera_3d()


## Sets the sprite as billboard and gets the starting orientation.
func _ready() -> void:
	billboard = BaseMaterial3D.BILLBOARD_ENABLED
	texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	_animation_group = "default"
	_determine_orientation()


## Updates the orientation to account for camera adjustements.
func _process(_delta: float) -> void:
	_determine_orientation()
	_match_animation_to_orientation()


## Updates the facing direction to match the given hex direction.
func face_hex_direction(direction: HexUtil.HexDirection) -> void:
	facing_direction = Vector2.UP.rotated(-HexUtil.dir_rotation(direction))


## Sets the animation to "idle".
func play_idle() -> void:
	_play_animation("idle")


## Sets the animation to "movement".
func play_movement() -> void:
	_play_animation("move")


## Starts the specified animation group, choosing the appropriate animation
## based on orientation.
func _play_animation(next_group: String) -> void:
	_animation_group = next_group
	frame = 0
	frame_progress = 0.0
	_match_animation_to_orientation()


## Determines the orientation the display should be in.
func _determine_orientation() -> void:
	var camera_dir_transform := _camera.global_transform.basis.z * -1
	var camera_dir := Vector2(
			camera_dir_transform.x,
			camera_dir_transform.z
	).normalized()
	var dot := camera_dir.dot(facing_direction)
	var right_facing := camera_dir.angle_to(facing_direction) >= 0.0
	if bind_to_hex:
		_hex_orientation(dot, right_facing)
	else:
		_default_orientation(dot, right_facing)


## Gets the orientation relative to standard directions.
func _default_orientation(dot: float, right_facing: bool) -> void:
	if dot >= 0.75:
		_orientation = DisplayOrientation.BACK
	elif dot < 0.75 and dot >= 0.25:
		_orientation = (
				DisplayOrientation.BACK_RIGHT if right_facing
				else DisplayOrientation.BACK_LEFT
		)
	elif dot < 0.25 and dot > -0.25:
		_orientation = (
				DisplayOrientation.RIGHT if right_facing
				else DisplayOrientation.LEFT
		)
	elif dot <= -0.25 and dot > -0.75:
		_orientation = (
				DisplayOrientation.FRONT_RIGHT if right_facing
				else DisplayOrientation.FRONT_LEFT
		)
	else:
		_orientation = DisplayOrientation.FRONT


## Gets the orientation relative to a hexagon.
func _hex_orientation(dot: float, right_facing: bool) -> void:
	if dot >= 0.9:
		_orientation = DisplayOrientation.BACK
	elif dot < 0.9 and dot >= 0.5:
		_orientation = (
				DisplayOrientation.BACK_RIGHT if right_facing
				else DisplayOrientation.BACK_LEFT
		)
	elif dot < 0.5 and dot > -0.5:
		_orientation = (
				DisplayOrientation.RIGHT if right_facing
				else DisplayOrientation.LEFT
		)
	elif dot <= -0.5 and dot > -0.9:
		_orientation = (
				DisplayOrientation.FRONT_RIGHT if right_facing
				else DisplayOrientation.FRONT_LEFT
		)
	else:
		_orientation = DisplayOrientation.FRONT


## Changes the active animation to match the current orientation.
func _match_animation_to_orientation() -> void:
	var animation_name := _animation_group + "_" + _orientation_string()
	if not sprite_frames.has_animation(animation_name):
		play("default")
		return
	var current_frame := frame
	var current_progress := frame_progress
	play(animation_name)
	set_frame_and_progress(current_frame, current_progress)


## Gets a string describing the orientation.
func _orientation_string() -> String:
	return String(DisplayOrientation.keys()[_orientation]).to_lower()
