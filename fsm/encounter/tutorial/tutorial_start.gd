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
	var starting_character := (
			tutorial.ui.initiative_tracker.get_current_character()
	)
	await starting_character.start_set
	tutorial.reset_initative_tracker()
	tutorial.set_step(Tutorial.Step.INTRO)
	tutorial.dialogue_panel.display()


## Virtual function. To be called in the _ready function to connect signals to 
## the state. The signals connected here should not be required by other states.
func _ready_connect_signals() -> void:
	tutorial.dialogue_panel.hidden.connect(_on_dialogue_hidden)


## Transitions to the `Instruction` state when the dialogue box is hidden.
func _on_dialogue_hidden() -> void:
	if not _state_is_active():
		return
	state_machine.transition_to(INSTRUCTION)
