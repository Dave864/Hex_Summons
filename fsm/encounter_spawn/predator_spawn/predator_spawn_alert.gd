class_name PredatorSpawnAlert
extends EncounterSpawnAlert
## The logic of the `Alert` state of a predator EncounterSpawn.
##
## The spawner immediately goes to the `Reaction` state. Predators flee from
## monsters. They will chase after prey that have a lower aggression. They will
## flee or chase player characters depending on their level.


## Goes to the `Reaction` state, the action being based on the type of focused
## target and other factors.
func _determine_reaction() -> void:
	var reaction_details: Dictionary[String, Variant] = {
		"pattern": EncounterSpawnReaction.BehaviorPattern.UNDECIDED,
		"reference_character": _alert_focus
	}
	if _alert_focus is EncounterSpawn:
		match _alert_focus.type:
			EncounterSpawn.Type.MONSTER:
				reaction_details["pattern"] = (
						EncounterSpawnReaction.BehaviorPattern.FLEE
				)
			EncounterSpawn.Type.PREY:
				# TODO: Update to account for future 'aggression' value.
				reaction_details["pattern"] = (
						EncounterSpawnReaction.BehaviorPattern.CHARGE
				)
			_:
				return
	else:
		# TODO: Update to account for player level.
		reaction_details["pattern"] = EncounterSpawnReaction.BehaviorPattern.PURSUE
