class_name OverworldAvatar
extends CharacterBody3D
## Represents the player character in the overworld scene.


## The speed the avatar moves at.
const SPEED = 7.0

## The sprite for the character.
@onready var _sprite: RotatingSprite3D = $RotatingSprite3D


## Orient the sprite to face forwards.
func _ready() -> void:
	_sprite.facing_direction = Vector2.DOWN
	_sprite.play_idle()


## Processes the physics of moving around.
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector(
			"player_move_l",
			"player_move_r",
			"player_move_u",
			"player_move_d"
	)
	# Only update facing direction if significant input has been provided.
	if not input_dir.is_zero_approx():
		_sprite.play_movement()
		_sprite.facing_direction = input_dir.normalized()
	else:
		_sprite.play_idle()
	var input_dir_vector := Vector3(input_dir.x, 0.0, input_dir.y)
	var direction := (transform.basis * input_dir_vector).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
