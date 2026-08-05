class_name MonsterSpawnAlert
extends EncounterSpawnAlert
## The logic of the `Alert` state of a monster EncounterSpawn.
##
## The spawner immediately goes to the `Reaction` state, specifying that it should
## chase after the focus of the alert.


## Goes to the `Reaction` state, specifying that the action should be to chase.
func _determine_reaction() -> void:
	pass
