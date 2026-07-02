class_name MonsterSpawnIdle
extends EncounterSpawnIdle
## The logic of the `Idle` state of a monster EncounterSpawn.
##
## The spawner can either roam around a point or travel to a point. When
## detecting anything, go to the `Alert` state.


## The behavior for determining what should happen when another EncounterSpawn
## is detected.
func _process_encounter_spawn(_spawn: EncounterSpawn) -> void:
	return
	#state_machine.transition_to(ALERT, {"AlertFocus": spawn})
