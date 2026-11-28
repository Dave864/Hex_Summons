class_name TutorialInstruction
extends TutorialState
## The logic for what happens when an Tutorial scene is in the `Instruction`
## state.
##
## The tutorial progresses to the next step, updating the dialogue and resetting
## the map to load the relevant enemies.When the text has been exhausted it
## goes to the corresponding character turn state.


## Called by the state machine upon changing the active state. The `msg` parameter
## is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> void:
	tutorial.selection_tracker.clear_highlights()
	tutorial.selection_tracker.clear_indicators()
	tutorial.progress_step()
	tutorial.dialogue_panel.exhausted.connect(_on_dialogue_exhausted)
	tutorial.dialogue_panel.display()


## Called by the state machine before changing the active state.
## Use this function to clean up the state.
func exit() -> void:
	tutorial.dialogue_panel.exhausted.disconnect(_on_dialogue_exhausted)


## Prepares to go into the next combat step.
func _on_dialogue_exhausted() -> void:
	tutorial.ui.emit_reactivated()
	var first_character := tutorial.get_current_character()
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
