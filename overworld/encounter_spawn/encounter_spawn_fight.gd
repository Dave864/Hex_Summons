class_name EncounterSpawnFight
extends EncounterSpawn
## An EncounterSpawn node that chases the OverworldAvatar upon spawning.


## The distance the spawner will chase before stopping.
var max_chase_distace: float = 2.0:
	get:
		return pow(max_chase_distace, 2.0)

## How far the spawner has traveled.
var _current_distance: float = 0.0


## Moves towards the OverworldAvatar. Despawns after traveling a set distance.
func _behavior_pattern(_delta: float) -> void:
	if not _active:
		return
	_nav_agent.target_position = _overworld_avatar.global_position
	_move_spawner()
	_update_chase_details()


## Updates the chase distance traveled.
func _update_chase_details() -> void:
	_current_distance += global_position.distance_squared_to(_prior_position)
	_prior_position = global_position
	if _current_distance >= max_chase_distace:
		despawn()
