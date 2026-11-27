class_name TutorialUIPause
extends TutorialUIState
## The logic for what happens when an TutorialUI scene is in the `Pause` state.
##
## Disables all interactable UI elements until they are needed.


## Virtual function. Called by the state machine upon changing the active state. 
## The `msg` parameter is a dictionary with arbitrary data the state can use to 
## initialize itself.
func enter(_msg := {}) -> void:
	tutorial_ui.disable_player_menu(true)


## Virtual function. Called by the state machine before changing the active 
## state. Use this function to clean up the state.
func exit() -> void:
	tutorial_ui.disable_player_menu(false)


## Connects the reactivated signal from the tutorial.
func _ready_connect_signals() -> void:
	tutorial_ui.reactivated.connect(_on_TutorialUI_reactivated)


## Goes to the `Wait` state when the UI is reactivated.
func _on_TutorialUI_reactivated() -> void:
	if not _state_is_active():
		return
	state_machine.transition_to(WAIT)
