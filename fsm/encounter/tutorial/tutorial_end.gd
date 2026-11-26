class_name TutorialEnd
extends TutorialState
## The logic for what happens when a Tutorial scene is in the `End` state.
##
## Activates the relevant popup depending on if the player won or lost.
## Goes to the overworld scene after the victory popup. Goes to the option
## selected in the defeat popup.


## The popup that appears declaring the result of the tutorial.
@export var end_popup: PopupPanel = null
## The window that clarifies what the player wants to do next.
@export var menu_window: Window = null

## The timer for the popup.
var _popup_timer: Timer = null
## The button that starts with focus upon upon opening the menu.
var _menu_focus_button: Button = null


## Connect the button and timer signals for the popups.
func _ready() -> void:
	super._ready()
	end_popup.popup_hide.connect(_on_popup_timer_timeout)
	_popup_timer = end_popup.get_node("Timer")
	_popup_timer.timeout.connect(_on_popup_timer_timeout)


## Called by the state machine upon changing the active state. The `msg` parameter
## is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> void:
	tutorial.set_step(Tutorial.Step.END)
	WispController.recall_all_to_players(tutorial.summon.summon_wisp_pool)
	get_tree().paused = true
	if tutorial.enemies_defeated():
		pass
	end_popup.show()
	_popup_timer.start()


## Reveals the end tutorial options menu.
func _on_popup_timer_timeout() -> void:
	# Time out can happen if menu is closed prematurely, so stop the timer to
	# prevent timeout from triggering again.
	_popup_timer.stop()
	menu_window.show()
	_menu_focus_button.grab_focus.call_deferred()


## Reloads the tutorial.
func _on_reset_pressed() -> void:
	get_tree().paused = false
	state_machine.transition_to(START)


## Loads the title screen. 
func _on_title_pressed() -> void:
	SceneController.reset_landmark()
	get_tree().paused = false
	SceneController.change_scene_to_title()


## Goes to the start of the game.
func _on_continue_pressed() -> void:
	SceneController.reset_landmark()
	get_tree().paused = false
	SceneController.change_scene_to_landmark_zone("TownStart")
