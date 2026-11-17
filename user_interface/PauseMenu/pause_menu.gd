class_name PauseMenu
extends Control
## Displays options for exiting to title, closing the game, or adjusting
## options.
##
## Pauses and unpauses the game state, additionally closing and opening the
## viewport it is specified to be contained in.


## The viewport container this menu is in.
@export var parent_viewport: SubViewportContainer = null
## The label that displays the current objective.
@export var objective_label: Label = null
## The stream player fo the sound that plays when the menu is opened.
@export var asp_open: AudioStreamPlayer = null
## The stream player fo the sound that plays when the menu is closed.
@export var asp_closed: AudioStreamPlayer = null


## Checks if the required node references have been set.
func _ready() -> void:
	assert(
			objective_label != null ,
			"No label for objective summaries has been set."
	)
	assert(asp_open != null, "No audio stream for open sound has been set.")
	assert(asp_closed != null, "No audio stream for closed sound has been set.")


## Opens itself when the options menu input has been detected.
func _input(event: InputEvent) -> void:
	if event.is_action("options_menu"):
		asp_open.play()
		if parent_viewport != null and not parent_viewport.visible:
			parent_viewport.show()
		get_tree().paused = true
	if event.is_action("ui_cancel"):
		asp_closed.play()
		get_tree().paused = false
		if parent_viewport != null and parent_viewport.visible:
			parent_viewport.hide()
