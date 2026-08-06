class_name MonsterSpawnReaction
extends EncounterSpawnReaction
## The logic of the `Reaction` state of a monster EncounterSpawn.
##
## Monster spawners do not consider other spawner types as threats, so they
## will maintain course if they detect other targets.


## Returns false as monster spawners do not have things that threaten them.
func _is_threat(_target: CharacterBody3D) -> bool:
	return false
