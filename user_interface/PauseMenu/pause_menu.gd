class_name PauseMenu
extends Control
## Displays options for exiting to title, closing the game, or adjusting
## options.
##
## Pauses and unpauses the game state, additionally closing and opening the
## viewport it is specified to be contained in.


## The states that this menu can be in.
enum State {CLOSED, OPEN, OPTIONS, CONFIRM_TITLE, CONFIRM_CLOSE}

## Message that clarifies if the player wants to exit to the title screen.
const CONFIRM_TEXT_TITLE := "Return to Title Screen?\n(game progress will reset)"
## Meesage that clarifies if the player wants to close the game.
const CONFIRM_TEXT_CLOSE := "Close the Game?"

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
## Flag indicating the current state of this menu.
var _menu_state := State.CLOSED
## The last Control node in focus before opening the pause menu.
var _prior_focus: Control = null
## Flag that inidicates that the pause menu is for the tutorial.
var _is_tutorial := false

## The timer that delays the changing from options to open.
@onready var _timer: Timer = $Timer
## The popup that asks for confirmation for certain selections.
@onready var _popup_confirm: PopupPanel = $PopupPanelConfirm


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
	_timer.timeout.connect(_on_timer_timeout)


## Opens itself when the options menu input has been detected.
func _input(event: InputEvent) -> void:
	if _menu_state == State.CLOSED and event.is_action_pressed("options_menu"):
		_prior_focus = get_tree().get_root().gui_get_focus_owner()
		_menu_state = State.OPEN
		if not _is_tutorial:
			objective_label.text = ObjectiveTracker.get_current_summary()
			_refresh_objective_trackers()
		asp_open.play()
		if parent_viewport != null and not parent_viewport.visible:
			parent_viewport.show()
			button_first_focus.grab_focus.call_deferred()
		get_tree().paused = true
	elif (
			_menu_state != State.CLOSED
			and (
				event.is_action_pressed("ui_cancel")
				or event.is_action_pressed("options_menu")
			)
	):
		if _menu_state != State.OPEN:
			return
		_menu_state = State.CLOSED
		asp_closed.play()
		get_tree().paused = false
		if _prior_focus == null:
			get_viewport().gui_release_focus()
		else:
			_prior_focus.grab_focus.call_deferred()
		if parent_viewport != null and parent_viewport.visible:
			parent_viewport.hide()


## Modifies the menu to follow tutorial standard.
func set_for_tutorial() -> void:
	_is_tutorial = true
	for node: Node in objective_label.get_children():
		if node is Control:
			node.hide()


## Updates the objective description.
func update_objective(objective: String) -> void:
	objective_label.text = objective


## Refreshes the objective trackers to reflect the current status of the
## ObjectiveTracker.
func _refresh_objective_trackers() -> void:
	var objectives_container := objective_label.get_child(0)
	for objective: Node in objectives_container.get_children():
		var objective_count: ObjectiveCount = objective.get_child(1)
		objective_count.refresh()


## Sets the pause menu to be open.
func _on_timer_timeout() -> void:
	_menu_state = State.OPEN


## Opens the options menu.
func _on_Options_button_pressed() -> void:
	_menu_state = State.OPTIONS
	options_viewport.show()
	_options_menu.open()


## Reveals a popup asking for confirmation.
func _on_Title_button_pressed() -> void:
	_menu_state = State.CONFIRM_TITLE
	_open_confirmation_popup()


## Reveals a popup asking for confirmation.
func _on_Close_button_pressed() -> void:
	_menu_state = State.CONFIRM_CLOSE
	_open_confirmation_popup()


## Opens the confirmation popup.
func _open_confirmation_popup() -> void:
	var popup_label: Label = _popup_confirm.get_node("VBoxContainer/Label")
	popup_label.text = (
			CONFIRM_TEXT_TITLE if _menu_state == State.CONFIRM_TITLE
			else CONFIRM_TEXT_CLOSE if _menu_state == State.CONFIRM_CLOSE
			else "ERROR!"
	)
	_popup_confirm.show()
	var button_focus: Button = _popup_confirm.get_node(
			"VBoxContainer/HBoxContainer/ButtonNo"
	)
	button_focus.grab_focus.call_deferred()


## Closes the confirmation popup.
func _on_PopupPanelConfirm_button_no_pressed() -> void:
	_menu_state = State.OPEN
	_popup_confirm.hide()


## Goes to the title screen or closes the game depending on the current menu
## state.
func _on_PopupPanelConfirm_button_yes_pressed() -> void:
	if _menu_state == State.CONFIRM_TITLE:
		get_tree().paused = false
		SceneController.change_scene_to_title()
	elif _menu_state == State.CONFIRM_CLOSE:
		get_tree().paused = false
		SceneController.close_game()


## Closes the options menu viewport.
func _on_Options_closed() -> void:
	options_viewport.hide()
	button_first_focus.grab_focus()
	_timer.start(0.2)
