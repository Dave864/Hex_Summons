extends EncounterState
"""
The logic for what happens when an Encounter scene is in the `Start` state.
Sets up the initiative tracker and current characater before moving to the 
corresponding `Turn` state. Goes immediately to the `End` state if the
starting character is not a valid type.
"""


# Class that defines the sort method for the encounter _initiative_tracker.
class InitiativeSorter:
	static func sort(a: Character, b: Character) -> bool:
		return a.stats.get_agl() < b.stats.get_agl()


# Called by the state machine upon changing the active state. The `msg` parameter
# is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> void:
	StateMachineBus.encounter_states["Encounter"] = "Start"
	_set_up_initative()
	
	# Goes 
	var current_character: Character = enc._initiative_tracker[enc._cur_init]
	if current_character is PlayerCharacter:
		state_machine.transition_to("PlayerTurn")
	elif current_character is EnemyCharacter:
		state_machine.transition_to("EnemyTurn")
	else:
		printerr(
			"Starting character is not of the PlayerCharacter " + \
			"or EnemyCharacter class."
		)
		state_machine.transition_to("End")


# Initializes the initiative tracker.
func _set_up_initative():
	enc._initiative_tracker.append_array(enc.players)
	enc._initiative_tracker.append_array(enc.enemies)
	enc._initiative_tracker.sort_custom(InitiativeSorter, "sort")
	enc._cur_init = 0
