class_name Title
extends Control
## The title screen for the game.
##
## Handles title screen and main menu operations, such as starting a new game,
## closing the game, and opening up options.


## The button to start the game
@onready var _start_button: Button = $ButtonContainer/Start


## Places focus on the start button.
func _ready() -> void:
	_start_button.grab_focus.call_deferred()


## Loads the overworld scene.
func _on_Start_pressed() -> void:
	SceneController.change_scene_to_overworld()


## Closes the game.
func _on_CloseGame_pressed() -> void:
	var scene_tree := get_tree()
	scene_tree.root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	scene_tree.quit()
