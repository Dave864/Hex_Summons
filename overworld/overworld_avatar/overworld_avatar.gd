class_name OverworldAvatar
extends CharacterBody3D
## Represents the player character in the overworld scene.


## The speed the avatar moves at.
const SPEED = 7.0


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
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
