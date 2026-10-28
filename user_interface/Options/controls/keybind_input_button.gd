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
## The deadzone value for joypad axis motion.
const JOYPAD_MOTION_DEADZONE := 0.5

## The source to look at for the key binding.
@export var input_source := InputController.Source.NONE
## The input the key will be bound to.
@export var input_bind := ""

## Records the keybind values for the given input for each input source.
var _key_binds: Dictionary[InputController.Source, InputEvent] = {
	SOURCE_GAMEPAD: null,
	SOURCE_KEYMOUSE: null,
	InputController.Source.NONE: null,
	InputController.Source.SWITCH_TO_GAMEPAD: null,
}
## Flag that indicates that a new keybind is being set for the input.
var _updating_bind := false
## Displays if the input bind is different from InputMap.
var _input_changed_icon: ActiveIcon = null
## Displays the texture icon for gamepad input.
var _gamepad_icon: GamepadIcon = null


## Sets the display to match the current settings.
func _ready() -> void:
	_create_gamepad_icon()
	_create_input_changed_icon()
	if not pressed.is_connected(_on_pressed):
		pressed.connect(_on_pressed)
	set_gamepad_keybinds_to_InputMap()
	set_keymouse_keybinds_to_InputMap()


## Sets the first valid input as the keybind for the specified input when a new
## keybind has been requested.
func _input(event: InputEvent) -> void:
	if not _updating_bind:
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
		_key_binds[input_source] = event
		_input_changed_icon.is_active = not matches_InputMap_bind()
		_update_display()
		new_bind_set.emit(get_instance_id())
		# Defer update setting to prevent button from getting stuck triggering
		# a rebind when setting ui_select input.
		call_deferred("_set_to_update", false)


## Returns the current gamepad keybind for the input event.
func gamepad_keybind() -> InputEvent:
	return _key_binds[SOURCE_GAMEPAD]


## Returns the current keymouse keybind for the input event.
func keymouse_keybind() -> InputEvent:
	return _key_binds[SOURCE_KEYMOUSE]


## Updates the button to reflect the gamepad keybind.
func set_input_to_gamepad() -> void:
	input_source = SOURCE_GAMEPAD
	_update_display()


## Updates the button to reflect the mouse and keyboard keybind.
func set_input_to_keymouse() -> void:
	input_source = SOURCE_KEYMOUSE
	_update_display()


## Resets the binding for the current input source to unassigned.
func clear_current_input_keybind() -> void:
	_key_binds[input_source] = null
	_input_changed_icon.is_active = true
	_update_display()


## Gets the shorthand text description of the binding for the current input
## source.
func get_current_input_keybind_text() -> String:
	return OptionsController.get_input_key_shorthand(
			UNASSIGNED if _key_binds[input_source] == null
			else _key_binds[input_source].as_text()
	)


## Sets the gamepad keybinds to their current value in InputMap.
func set_gamepad_keybinds_to_InputMap() -> void:
	_key_binds[SOURCE_GAMEPAD] = null
	if InputMap.has_action(input_bind):
		for event: InputEvent in InputMap.action_get_events(input_bind):
			if (
					(
						event is InputEventJoypadMotion
						or event is InputEventJoypadButton
					)
					and _key_binds[SOURCE_GAMEPAD] == null
			):
				_key_binds[SOURCE_GAMEPAD] = event
			elif _key_binds[SOURCE_GAMEPAD] != null:
				# Only a single key should be exposed by this button, so we only
				# look at the first one to appear.
				break
	_update_display()


## Sets the keymouse keybinds to their current value in InputMap.
func set_keymouse_keybinds_to_InputMap() -> void:
	_key_binds[SOURCE_KEYMOUSE] = null
	if InputMap.has_action(input_bind):
		for event: InputEvent in InputMap.action_get_events(input_bind):
			if (
					(
						event is InputEventMouse or event is InputEventKey
					)
					and _key_binds[SOURCE_KEYMOUSE] == null
			):
				_key_binds[SOURCE_KEYMOUSE] = event
			elif _key_binds[SOURCE_KEYMOUSE] != null:
				# Only a single key should be exposed by this button, so we only
				# look at the first one to appear.
				break
	_update_display()


## Updates the input changed icon to indicate that the input is unchanged.
func mark_as_unchanged() -> void:
	_input_changed_icon.is_active = false


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
		var event_text := OptionsController.get_input_key_shorthand(
				event.as_text()
		)
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


## Creates an ActiveIcon to indicate if this input has changed from its
## original state.
func _create_input_changed_icon() -> void:
	_input_changed_icon = ActiveIcon.new()
	add_child(_input_changed_icon)
	_input_changed_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_input_changed_icon.set_anchors_preset(Control.PRESET_CENTER_RIGHT, true)
	_input_changed_icon.grow_vertical = Control.GROW_DIRECTION_BOTH
	var active_size := _input_changed_icon.active_texture.get_size()
	var inactive_size := _input_changed_icon.inactive_texture.get_size()
	_input_changed_icon.offset_left = -active_size.x
	_input_changed_icon.offset_top = -inactive_size.y / 2.0
	_input_changed_icon.offset_bottom = inactive_size.y / 2.0


## Updates the display to reflect the current keybind.
func _update_display() -> void:
	if input_source == SOURCE_GAMEPAD:
		_gamepad_icon.show()
		_gamepad_icon.update_for_event(_key_binds[SOURCE_GAMEPAD])
		text = UNASSIGNED if _gamepad_icon.texture == null else ""
	else:
		text = OptionsController.get_input_key_shorthand(
				UNASSIGNED if _key_binds[input_source] == null
				else _key_binds[input_source].as_text()
		)
		_gamepad_icon.hide()


## Sets the disabled and updating_bind flags. This is to allow these operations
## to be deferred.
func _set_to_update(state: bool) -> void:
	disabled = state
	_updating_bind = state


## Indicates that a new keybind has been requested and readies the button to
## recieve new valid input.
func _on_pressed() -> void:
	# Don't want to retrigger rebind while a new bind is being set.
	if _updating_bind:
		return
	new_bind_requested.emit(input_source)
	_set_to_update(true)
