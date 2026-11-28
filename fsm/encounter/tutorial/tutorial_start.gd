class_name TutorialStart
extends TutorialState
## The logic for what happens when an Tutorial scene is in the `Start` state.
##
## Sets up the initiative tracker and current characater before displaying the
## introdution message. Transitions to the `Instruction` state once the intro
## dialogue has been exhausted.


## Called by the state machine upon changing the active state. The `msg` parameter
## is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> void:
	tutorial.reset_initative_tracker()
	var starting_character := (
			tutorial.ui.initiative_tracker.get_current_character()
	)
	await starting_character.start_set
	tutorial.set_step(Tutorial.Step.INTRO)
	tutorial.dialogue_panel.exhausted.connect(_on_dialogue_exhausted)
	tutorial.dialogue_panel.display()


## Called by the state machine before changing the active state.
## Use this function to clean up the state.
func exit() -> void:
	tutorial.dialogue_panel.exhausted.disconnect(_on_dialogue_exhausted)


## Transitions to the `Instruction` state when the dialogue box is exhausted.
func _on_dialogue_exhausted() -> void:
	state_machine.transition_to(INSTRUCTION)
