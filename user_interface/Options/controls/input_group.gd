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


## Gets the keybind buttons of this input group.
func _ready() -> void:
	InputController.input_source_changed.connect(
			_on_InputController_input_source_changed
	)
	for item: Node in $VBoxContainer.get_children():
		var input_button: KeybindInputButton = item.get_child(1)
		_input_binds[input_button.get_instance_id()] = input_button
		input_button.new_bind_set.connect(_on_KeybindInputButton_new_bind_set)


## Gets the input binding buttons for this group.
func get_binding_buttons() -> Array[KeybindInputButton]:
	return _input_binds.values()


## Returns if the currently set keybinds for the current input source are all
## unique. If any keybinds are not set, the keybinds are not considered unique.
func all_bindings_unique() -> bool:
	var bound_inputs: Dictionary[String, bool] = {}
	var all_unique_keybinds = true
	for bind_button: KeybindInputButton in _input_binds.values():
		# Not all bindings may be avaiable for all input sources. Those that
		# aren't for the current input source are made hidden and should not
		# be evaluated.
		if not bind_button.visible:
			continue
		var keybind_text := bind_button.get_current_input_keybind_text()
		if (
				bound_inputs.has(keybind_text)
				or keybind_text == KeybindInputButton.UNASSIGNED
		):
			all_unique_keybinds = false
		bound_inputs[keybind_text] = true
	return all_unique_keybinds


## Goes through all binding buttons and resets them to reflect the InputMap.
func reset_bindings_to_InputMap() -> void:
	# This method resets the binding buttons to an unchanged state, meaning that
	# the group should not be considered updated.
	updated_icon.is_active = false
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
		# Binding button is being reset to unchanged, so its active icon should
		# reflect that.
		bind_button.mark_as_unchanged()


## Changes any existing keybinds that match the new bind to be unassigned, also
## updating the active flag for each.
func _on_KeybindInputButton_new_bind_set(id: int) -> void:
	var event_name = _input_binds[id].get_current_input_keybind_text()
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
			updated_icon.is_active = true
		else:
			updated_icon.is_active = (
					true if not bind_button.matches_InputMap_bind()
					else updated_icon.is_active
			)


## Sets all input binding buttons to reflect current InputMap bindings.
func _on_InputController_input_source_changed() -> void:
	# Don't swap if popup is present as an input bind is being set.
	if confirm_popup.visible:
		return
	reset_bindings_to_InputMap()
