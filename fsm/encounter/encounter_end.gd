class_name EncounterEnd
extends EncounterState
## The logic for what happens when an Encounter scene is in the `End` state.
##
## Activates the relevant popup depending on if the player won or lost.
## Goes to the overworld scene after the victory popup. Goes to the option
## selected in the defeat popup.


## The popup that appears when the player wins.
@export var victory_popup: PopupPanel = null
## The popup that appears when the player loses.
@export var defeat_popup: PopupPanel = null

## The timer for the victory popup.
var _victory_timer: Timer = null
## The button that starts with focus upon defeat.
var _defeat_focus_button: Button = null


## Connect the button and timer signals for the popups.
func _ready() -> void:
	super._ready()
	victory_popup.popup_hide.connect(_on_victory_timeout)
	_victory_timer = victory_popup.get_node("Timer")
	_victory_timer.timeout.connect(_on_victory_timeout)
	var reset_button: Button = defeat_popup.get_node(
			"VBoxContainer/HBoxContainer/ResetButton"
	)
	_defeat_focus_button = reset_button
	reset_button.pressed.connect(_on_defeat_reset_pressed)
	var title_button: Button = defeat_popup.get_node(
			"VBoxContainer/HBoxContainer/TitleButton"
	)
	title_button.pressed.connect(_on_defeat_title_pressed)
	var close_button: Button = defeat_popup.get_node(
			"VBoxContainer/HBoxContainer/CloseButton"
	)
	close_button.pressed.connect(_on_defeat_close_pressed)


## Called by the state machine upon changing the active state. The `msg` parameter
## is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> void:
	WispController.recall_all_to_players(enc.summon.summon_wisp_pool)
	get_tree().paused = true
	if enc.enemies_defeated():
		victory_popup.show()
		_victory_timer.start()
	else:
		defeat_popup.show()
		_defeat_focus_button.grab_focus.call_deferred()


## Goes back to the overworld.
func _on_victory_timeout() -> void:
	# Time out can happen if menu is closed prematurely, so stop the timer to
	# prevent timeout from triggering again.
	_victory_timer.stop()
	get_tree().paused = false
	SceneController.change_scene_to_overworld()


## Loads the start of the game.
func _on_defeat_reset_pressed() -> void:
	SceneController.reset_landmark()
	get_tree().paused = false
	SceneController.change_scene_to_landmark_zone("TownStart")


## Loads the title screen. 
func _on_defeat_title_pressed() -> void:
	SceneController.reset_landmark()
	get_tree().paused = false
	SceneController.change_scene_to_title()


## Closes the game.
func _on_defeat_close_pressed() -> void:
	SceneController.close_game()
