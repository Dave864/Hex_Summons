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

## The set of input binding buttons.
var _input_binds: Dictionary[int, KeybindInputButton] = {}
## Flag that indicates if all bindings are valid/unique.
var _all_unique_keybinds := true


## Gets the keybind buttons of this input group.
func _ready() -> void:
	for item: Node in $VBoxContainer.get_children():
		var input_button: KeybindInputButton = item.get_child(1)
		_input_binds[input_button.get_instance_id()] = input_button
		input_button.new_bind_set.connect(_on_KeybindInputButton_new_bind_set)


## Returns if the currently set keybinds for the current input source are all
## unique.
func all_bindings_unique() -> bool:
	return _all_unique_keybinds


## Changes any existing keybinds that match the new bind to be unassigned, also
## updating the active flag for each.
func _on_KeybindInputButton_new_bind_set(id: int) -> void:
	var event_name = _input_binds[id].text
	_all_unique_keybinds = true
	updated_icon.is_active = false
	for bind_id: int in _input_binds.keys():
		var bind_button := _input_binds[bind_id]
		if not bind_button.visible:
			continue
		if (
				bind_button.get_instance_id() != id
				and bind_button.text == event_name
		):
			bind_button.clear_current_input_keybind()
			_all_unique_keybinds = false
			bind_button.get_child(0).is_active = true
			updated_icon.is_active = true
		else:
			var bind_changed := not bind_button.matches_old_bind()
			bind_button.get_child(0).is_active = bind_changed
			updated_icon.is_active = (
					true if bind_changed else updated_icon.is_active
			)
