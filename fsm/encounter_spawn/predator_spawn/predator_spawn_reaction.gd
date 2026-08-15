class_name PredatorSpawnReaction
extends EncounterSpawnReaction
## The logic of the `Reaction` state of a monster EncounterSpawn.
##
## Predators consider all monsters threats, and predators and prey of higher
## aggression as threats. If the player character is of higher level, they
## will also be seen as a threat.


## Returns if the target is considered a threat.
func _is_threat(target: CharacterBody3D) -> bool:
	if target is EncounterSpawn:
		match target.type:
			EncounterSpawn.Type.MONSTER:
				return true
			EncounterSpawn.Type.PREDATOR:
				# TODO: Update to check aggression.
				return true
			EncounterSpawn.Type.PREY:
				# TODO: Update to check aggression.
				return false
	# TODO: Update to account for player level.
	return false
