class_name MonsterSpawnIdle
extends EncounterSpawnIdle
## The logic of the `Idle` state of a monster EncounterSpawn.
##
## The spawner can either roam around a point or travel to a point. When
## detecting anything, go to the `Alert` state.


## The behavior for determining what should happen when another EncounterSpawn
## is detected.
func _process_encounter_spawn(spawn: EncounterSpawn) -> void:
	if spawn.type == EncounterSpawn.Type.MONSTER:
		return
	state_machine.transition_to(ALERT, {"AlertFocus": spawn})
