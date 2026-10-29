class_name Title
extends Control
## The title screen for the game.
##
## Handles title screen and main menu operations, such as starting a new game,
## closing the game, and opening up options.


## The button to start the game
@export var start_button: Button = null
## The button to open the options menu.
@export var options_button: Button = null
## The viewport for the Options menu.
@export var options_viewport: SubViewportContainer = null
## The options menu.
@export var options_menu: Options = null


## Places focus on the start button.
func _ready() -> void:
	start_button.grab_focus.call_deferred()


## Loads the overworld scene.
func _on_Start_pressed() -> void:
	SceneController.change_scene_to_overworld()


## Opens the options menu.
func _on_Options_pressed() -> void:
	options_viewport.show()
	options_menu.open()


## Closes the game.
func _on_CloseGame_pressed() -> void:
	var scene_tree := get_tree()
	scene_tree.root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	scene_tree.quit()


## Closes the options menu viewport.
func _on_OptionsMenu_closed() -> void:
	options_viewport.hide()
	options_button.grab_focus.call_deferred()
