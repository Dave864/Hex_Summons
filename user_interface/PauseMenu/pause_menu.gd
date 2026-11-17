class_name PauseMenu
extends Control
## Displays options for exiting to title, closing the game, or adjusting
## options.
##
## Pauses and unpauses the game state, additionally closing and opening the
## viewport it is specified to be contained in.


## The viewport container this menu is in.
@export var parent_viewport: SubViewportContainer = null
## The viewport for the options menu.
@export var options_viewport: SubViewportContainer = null
## The label that displays the current objective.
@export var objective_label: Label = null
## Button that the pause menu sets focus on when it opens.
@export var button_first_focus: Button = null
@export_group("Audio", "asp_")
## The stream player fo the sound that plays when the menu is opened.
@export var asp_open: AudioStreamPlayer = null
## The stream player fo the sound that plays when the menu is closed.
@export var asp_closed: AudioStreamPlayer = null

## The options menu.
var _options_menu: Options = null
## Flag indicating that this menu is open.
var _is_open := false


## Checks if the required node references have been set.
func _ready() -> void:
	assert(
			options_viewport != null,
			"Viewport for options has not been specified."
	)
	assert(
			objective_label != null ,
			"No label for objective summaries has been set."
	)
	assert(
			button_first_focus != null,
			"No button has been set for first focus."
	)
	assert(asp_open != null, "No audio stream for open sound has been set.")
	assert(asp_closed != null, "No audio stream for closed sound has been set.")
	_options_menu = options_viewport.get_child(0).get_child(0)


## Opens itself when the options menu input has been detected.
func _input(event: InputEvent) -> void:
	if not _is_open and event.is_action("options_menu"):
		_is_open = true
		objective_label.text = ObjectiveTracker.get_current_summary()
		asp_open.play()
		if parent_viewport != null and not parent_viewport.visible:
			parent_viewport.show()
			button_first_focus.grab_focus.call_deferred()
		get_tree().paused = true
	if _is_open and event.is_action("ui_cancel"):
		_is_open = false
		asp_closed.play()
		get_tree().paused = false
		if parent_viewport != null and parent_viewport.visible:
			parent_viewport.hide()


## Opens the options menu.
func _on_Options_button_pressed() -> void:
	options_viewport.show()
	_options_menu.open()


## Reveals a popup asking for confirmation.
func _on_Title_button_pressed() -> void:
	pass


## Reveals a popup asking for confirmation.
func _on_Close_button_pressed() -> void:
	pass


## Closes the options menu viewport.
func _on_Options_closed() -> void:
	options_viewport.hide()
	button_first_focus.grab_focus()
