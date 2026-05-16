class_name EncounterSpawnFight
extends EncounterSpawn
## An EncounterSpawn node that chases the OverworldAvatar upon spawning.


## The distance the spawner will chase before stopping.
var max_chase_distace: float = 1.0

## How far the spawner has traveled.
var _current_distance: float = 0.0
## The position of the spawner in the last frame.
var _prior_position := Vector3.ZERO


## Moves towards the OverworldAvatar. Despawns after traveling a set distance.
func _behavior_pattern(_delta: float) -> void:
	var input_dir := position.direction_to(_overworld_avatar.position)
	_move_spawner(input_dir)
	_update_chase_details()


## Updates the chase distance traveled.
func _update_chase_details() -> void:
	_current_distance += position.distance_squared_to(_prior_position)
	_prior_position = position
	if _current_distance >= max_chase_distace:
		despawn()
