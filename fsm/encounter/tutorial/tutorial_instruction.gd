class_name TutorialInstruction
extends TutorialState
## The logic for what happens when an Tutorial scene is in the `Instruction`
## state.
##
## The tutorial progresses to the next step, updating the dialogue and resetting
## the map to load thhe relevant enemies.When the text has been exhausted it
## goes to the corresponding character turn state.


## Called by the state machine upon changing the active state. The `msg` parameter
## is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> void:
	tutorial.progress_step()
	tutorial.dialogue_panel.display()


## Virtual function. To be called in the _ready function to connect signals to 
## the state. The signals connected here should not be required by other states.
func _ready_connect_signals() -> void:
	tutorial.dialogue_panel.hidden.connect(_on_dialogue_hidden)


## Prepares to go into the next combat step.
func _on_dialogue_hidden() -> void:
	if not _state_is_active():
		return
	var first_character := tutorial.get_next_character()
	if first_character is PlayerCharacter:
		if (
				tutorial.summon.is_active()
				and tutorial.summon.summoner == first_character
		):
			state_machine.transition_to(SUMMON_TURN)
		else:
			state_machine.transition_to(PLAYER_TURN)
	elif first_character is EnemyCharacter:
		state_machine.transition_to(ENEMY_TURN)
