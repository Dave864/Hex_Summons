class_name InputGroup
extends ScrollContainer
## Manages a set of keybind inputs, making sure that each one has a unique
## input.
##
## Whenever a new keybind is set, all other keybinds are looked at and any ones
## that have the same key are set to unassigned. Only looks at inputs that are
## visible.


## The icon for indicating that some of this group's input controls are
## different from the current settings.
@export var updated_icon: ActiveIcon = null
## Popup for confirming input.
@export var confirm_popup: PopupConfirmInput = null

## The set of input binding buttons.
var _input_binds: Dictionary[int, KeybindInputButton] = {}
## The current input source.
var _current_source: InputController.Source
## Flag that indicates if all bindings are valid/unique.
var _all_unique_keybinds := true


## Gets the keybind buttons of this input group.
func _ready() -> void:
	_current_source = InputController.get_source()
	for item: Node in $VBoxContainer.get_children():
		var input_button: KeybindInputButton = item.get_child(1)
		_input_binds[input_button.get_instance_id()] = input_button
		input_button.new_bind_set.connect(_on_KeybindInputButton_new_bind_set)


## Sets all input binding buttons to reflect current InputMap bindings when input
## source changes.
func _process(_delta: float) -> void:
	# Don't swap if popup is present as an input bind is being set. Don't need
	# to redo update logic if input source has not changed.
	if confirm_popup.visible or _current_source == InputController.get_source():
		return
	_reset_bindings_to_InputMap()
	_current_source = InputController.get_source()
	_check_if_bindings_unique()
	_mark_changed_bindings()


## Returns if the currently set keybinds for the current input source are all
## unique.
func all_bindings_unique() -> bool:
	return _all_unique_keybinds


## Goes through all binding buttons and resets them to reflect the InputMap.
func _reset_bindings_to_InputMap() -> void:
	for bind_button: KeybindInputButton in _input_binds.values():
		# Not all bindings may be avaiable for all input sources. Those that
		# aren't for the current input source are made hidden and should not
		# be affected.
		if not bind_button.visible:
			continue
		if InputController.source_is_gamepad():
			bind_button.set_gamepad_keybinds_to_InputMap()
		else:
			bind_button.set_keymouse_keybinds_to_InputMap()


## Goes through the binding buttons and checks if all of them are set to unique
## input events.
func _check_if_bindings_unique() -> void:
	var bound_inputs: Dictionary[String, bool] = {}
	_all_unique_keybinds = true
	for bind_button: KeybindInputButton in _input_binds.values():
		# Not all bindings may be avaiable for all input sources. Those that
		# aren't for the current input source are made hidden and should not
		# be affected.
		if not bind_button.visible:
			continue
		if bound_inputs.has(bind_button.text):
			_all_unique_keybinds = false
		bound_inputs[bind_button.text] = true


## Goes through the binding buttons and marks if any of them have input bindings
## that are different from the current InputMap.
func _mark_changed_bindings() -> void:
	updated_icon.is_active = false
	for bind_button: KeybindInputButton in _input_binds.values():
		# Not all bindings may be avaiable for all input sources. Those that
		# aren't for the current input source are made hidden and should not
		# be affected.
		if not bind_button.visible:
			continue
		var bind_changed := not bind_button.matches_InputMap_bind()
		bind_button.get_child(0).is_active = bind_changed
		updated_icon.is_active = (
				true if bind_changed else updated_icon.is_active
		)


## Changes any existing keybinds that match the new bind to be unassigned, also
## updating the active flag for each.
func _on_KeybindInputButton_new_bind_set(id: int) -> void:
	var event_name = _input_binds[id].get_current_input_keybind_text()
	_all_unique_keybinds = true
	updated_icon.is_active = false
	for bind_id: int in _input_binds.keys():
		var bind_button := _input_binds[bind_id]
		# Not all bindings may be avaiable for all input sources. Those that
		# aren't for the current input source are made hidden and should not
		# be affected.
		if not bind_button.visible:
			continue
		var bind_button_text := bind_button.get_current_input_keybind_text()
		if (
				bind_button.get_instance_id() != id
				and bind_button_text == event_name
		):
			bind_button.clear_current_input_keybind()
			_all_unique_keybinds = false
			bind_button.get_child(0).is_active = true
			updated_icon.is_active = true
		else:
			var bind_changed := not bind_button.matches_InputMap_bind()
			bind_button.get_child(0).is_active = bind_changed
			updated_icon.is_active = (
					true if bind_changed else updated_icon.is_active
			)
