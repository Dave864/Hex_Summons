class_name KeybindInputButton
extends Button
## Button that lets a player select the key used for a specific input.
##
## Able to specify the key source for the input (gamepad or mouse & keyboard),
## tracking the selection for each source as a string that is relevant to
## Godot's project input map. Does not override the input, merely specify the
## desired keybind.


## Indicates that a new input keybind is being requested by this button.
signal new_bind_requested(input_source)
## Indicates that a new input keybind has been set. Returns the id of this
## control.
signal new_bind_set(id)

## Text displayed when no value is assigned.
const UNASSIGNED := "NONE"
## Shorthand for InputController's GAMEPAD Source enum.
const SOURCE_GAMEPAD := InputController.Source.GAMEPAD
## Shorthand for InputController's KEYBOARD_AND_MOUSE Source enum.
const SOURCE_KEYMOUSE := InputController.Source.KEYBOARD_AND_MOUSE
## Shorthand for InputController's NONE Source enum.
const SOURCE_NONE := InputController.Source.NONE
## The deadzone value for joypad axis motion.
const JOYPAD_MOTION_DEADZONE := 0.5
## Map to shorthand for various event text.
const INPUT_EVENT_SHORTHAND := {
	"Left Mouse Button": "Left Click",
	"Right Mouse Button": "Right Click",
	"Middle Mouse Button": "Middle Click",
	"Mouse Wheel Up": "Scroll Up",
	"Mouse Wheel Down": "Scroll Down",
	"Escape": "Esc",
	"QuoteLeft": "`",
	"Minus": "-",
	"Equal": "=",
	"BackSlash": "\\",
	"BracketLeft": "[",
	"BracketRight": "]",
	"Semicolon": ";",
	"Apostrophe": "'",
	"Comma": ",",
	"Period": ".",
	"Slash": "/",
	"Kp Divide": "/",
	"Kp Multiply": "*",
	"Kp Subtract": "-",
	"Kp Add": "+",
	"Kp Period": ".",
	"Kp Enter": "Enter",
	"Kp 1": "1",
	"Kp 2": "2",
	"Kp 3": "3",
	"Kp 4": "4",
	"Kp 5": "5",
	"Kp 6": "6",
	"Kp 7": "7",
	"Kp 8": "8",
	"Kp 9": "9",
}

## The source to look at for the key binding.
@export var input_source := InputController.Source.NONE
## The input the key will be bound to.
@export var input_bind := ""

## Records the keybind values for the given input for each input source.
var key_bind: Dictionary[InputController.Source, InputEvent] = {
	SOURCE_GAMEPAD: null,
	SOURCE_KEYMOUSE: null,
	SOURCE_NONE: null,
}
## Flag that indicates that a new keybind is being set for the input.
var updating_bind := false

## Displays the texture icon for gamepad input.
var _gamepad_icon: GamepadIcon = null


## Sets the display to match the current settings.
func _ready() -> void:
	_create_gamepad_icon()
	if not pressed.is_connected(_on_pressed):
		pressed.connect(_on_pressed)
	set_gamepad_keybinds_to_InputMap()
	set_keymouse_keybinds_to_InputMap()


## Sets the first valid input as the keybind for the specified input when a new
## keybind has been requested.
func _input(event: InputEvent) -> void:
	if not updating_bind:
		return
	var use_event_as_bind := false
	# Only uses significant movement in a direction as valid joystick input.
	if input_source == SOURCE_GAMEPAD and event is InputEventJoypadMotion:
		use_event_as_bind = absf(event.axis_value) > JOYPAD_MOTION_DEADZONE
	elif (
			(
				(event is InputEventKey or event is InputEventMouseButton)
				and input_source == SOURCE_KEYMOUSE
			)
			or (
				event is InputEventJoypadButton
				and input_source == SOURCE_GAMEPAD
			)
	):
		use_event_as_bind = true
	if use_event_as_bind:
		# Don't want to have double clicks as events.
		if event is InputEventMouseButton:
			event.double_click = false
		key_bind[input_source] = event
		_update_display()
		new_bind_set.emit(get_instance_id())
		# Defer update setting to prevent button from getting stuck triggering
		# a rebind when setting ui_select input.
		call_deferred("_set_to_update", false)


## Updates the button to reflect the gamepad keybind.
func set_input_to_gamepad() -> void:
	input_source = SOURCE_GAMEPAD
	_update_display()


## Updates the button to reflect the mouse and keyboard keybind.
func set_input_to_keymouse() -> void:
	input_source = SOURCE_KEYMOUSE
	_update_display()


## Resets the current bindings to unassigned.
func clear_keybinds() -> void:
	key_bind[SOURCE_GAMEPAD] = null
	key_bind[SOURCE_KEYMOUSE] = null
	_update_display()


## Resets the current gamepad binding to unassigned.
func clear_gamepad_keybind() -> void:
	key_bind[SOURCE_GAMEPAD] = null
	_update_display()


## Resets the current keymouse binding to unassigned.
func clear_keymouse_keybind() -> void:
	key_bind[SOURCE_KEYMOUSE] = null
	_update_display()


## Resets the binding for the current input source to unassigned.
func clear_current_input_keybind() -> void:
	key_bind[input_source] = null
	_update_display()


## Gets the shorthand text description of the binding for the current input
## source.
func get_current_input_keybind_text() -> String:
	var bound_event_text := (
			UNASSIGNED if key_bind[input_source] == null
			else key_bind[input_source].as_text()
	)
	if INPUT_EVENT_SHORTHAND.has(bound_event_text):
		bound_event_text = INPUT_EVENT_SHORTHAND[bound_event_text]
	return bound_event_text


## Sets the gamepad keybinds to their current value in InputMap.
func set_gamepad_keybinds_to_InputMap() -> void:
	key_bind[SOURCE_GAMEPAD] = null
	if InputMap.has_action(input_bind):
		for event: InputEvent in InputMap.action_get_events(input_bind):
			if (
					(
						event is InputEventJoypadMotion
						or event is InputEventJoypadButton
					)
					and key_bind[SOURCE_GAMEPAD] == null
			):
				key_bind[SOURCE_GAMEPAD] = event
			elif key_bind[SOURCE_GAMEPAD] != null:
				# Only a single key should be exposed by this button, so we only
				# look at the first one to appear.
				break
	_update_display()


## Sets the keymouse keybinds to their current value in InputMap.
func set_keymouse_keybinds_to_InputMap() -> void:
	key_bind[SOURCE_KEYMOUSE] = null
	if InputMap.has_action(input_bind):
		for event: InputEvent in InputMap.action_get_events(input_bind):
			if (
					(
						event is InputEventMouse or event is InputEventKey
					)
					and key_bind[SOURCE_KEYMOUSE] == null
			):
				key_bind[SOURCE_KEYMOUSE] = event
			elif key_bind[SOURCE_KEYMOUSE] != null:
				# Only a single key should be exposed by this button, so we only
				# look at the first one to appear.
				break
	_update_display()


## Checks if the current input bind for the current input source is the same
## as the input map.
func matches_InputMap_bind() -> bool:
	var bound_event_text := get_current_input_keybind_text()
	var old_bind_present := false
	for event: InputEvent in InputMap.action_get_events(input_bind):
		if (
				(
					input_source == SOURCE_GAMEPAD
					and (
						event is InputEventJoypadButton
						or event is InputEventJoypadMotion
					)
				)
				or (
					input_source == SOURCE_KEYMOUSE
					and (event is InputEventKey or event is InputEventMouse)
				)
		):
			old_bind_present = true
		var event_text := event.as_text()
		if INPUT_EVENT_SHORTHAND.has(event_text):
			event_text = INPUT_EVENT_SHORTHAND[event_text]
		if event_text == bound_event_text:
			return true
	return (
			true if bound_event_text == UNASSIGNED and not old_bind_present
			else false
	)


## Creates a GamepadIcon to display gamepad input.
func _create_gamepad_icon() -> void:
	_gamepad_icon = GamepadIcon.new()
	add_child(_gamepad_icon)
	_gamepad_icon.set_anchors_preset(Control.PRESET_FULL_RECT, true)
	_gamepad_icon.offset_left = 5.0
	_gamepad_icon.offset_right = -5.0
	_gamepad_icon.offset_top = 4.0
	_gamepad_icon.offset_bottom = -4.0


## Updates the display to reflect the current keybind.
func _update_display() -> void:
	if input_source == SOURCE_GAMEPAD:
		_gamepad_icon.show()
		_gamepad_icon.update_for_event(key_bind[SOURCE_GAMEPAD])
		text = UNASSIGNED if _gamepad_icon.texture == null else ""
	else:
		text = (
				UNASSIGNED if key_bind[input_source] == null
				else key_bind[input_source].as_text()
		)
		if INPUT_EVENT_SHORTHAND.has(text):
			text = INPUT_EVENT_SHORTHAND[text]
		_gamepad_icon.hide()


## Sets the disabled and updating_bind flags. This is to allow these operations
## to be deferred.
func _set_to_update(state: bool) -> void:
	disabled = state
	updating_bind = state


## Indicates that a new keybind has been requested and readies the button to
## recieve new valid input.
func _on_pressed() -> void:
	# Don't want to retrigger rebind while a new bind is being set.
	if updating_bind:
		return
	new_bind_requested.emit(input_source)
	_set_to_update(true)
