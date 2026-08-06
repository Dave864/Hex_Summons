class_name MonsterSpawnAlert
extends EncounterSpawnAlert
## The logic of the `Alert` state of a monster EncounterSpawn.
##
## The spawner immediately goes to the `Reaction` state, specifying that it should
## chase after the focus of the alert.


## Goes to the `Reaction` state, specifying that the action should be to chase.
func _determine_reaction() -> void:
	var reaction_details: Dictionary[String, Variant] = {
		"pattern": EncounterSpawnReaction.BehaviorPattern.PURSUE,
		"reference_character": _alert_focus
	}
	state_machine.transition_to(REACTION, reaction_details)
