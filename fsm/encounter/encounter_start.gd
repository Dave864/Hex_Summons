class_name EncounterStart
extends EncounterState
## The logic for what happens when an Encounter scene is in the `Start` state.
##
## Sets up the initiative tracker and current characater before moving to the 
## corresponding `Turn` state. Goes immediately to the `End` state if the
## starting character is not a valid type.


var starting_character: Character


## Called by the state machine upon changing the active state. The `msg` parameter
## is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> void:
	_set_up_initative()
	starting_character = enc.ui.initiative_tracker.get_current_character()
	await starting_character.start_set
	if starting_character is PlayerCharacter:
		state_machine.transition_to(PLAYER_TURN)
	elif starting_character is EnemyCharacter:
		state_machine.transition_to(ENEMY_TURN)
	else:
		printerr(
			"Starting character is not of the PlayerCharacter " + \
			"or EnemyCharacter class."
		)
		state_machine.transition_to(END)


## Initializes the initiative tracker.
func _set_up_initative() -> void:
	var characters: Array = []
	characters.append_array(enc.players)
	characters.append_array(enc.enemies)
	enc.ui.initiative_tracker.populate_initiative(characters)
