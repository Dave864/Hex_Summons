class_name InputOptionProperty
extends EditorProperty
## Custom property inspector that allows for the selection of inputs from a
## drop-down menu.
##
## Creates an option button for all possible inputs in InputMap singleton. This
## allows for the simple selection of an input instead of going through the
## project settings to find the name of the desired input.


## The button that contains the input options available.
var _input_options: OptionButton
## The currently selected input.
var _current_input: String


## Create option button.
func _init() -> void:
	_input_options = OptionButton.new()
	add_child(_input_options)
	_input_options.item_selected.connect(_on_input_option_item_selected)
	for name: String in _get_input_names():
		_input_options.add_item(name)


## Gets the names of the input actions from the PropertySettings as InputMap
## only retrieves editor input maps while running in editor.
func _get_input_names() -> PackedStringArray:
	return PackedStringArray(
		ProjectSettings.get_property_list()
		.map(func(prop): return prop.name)
		.filter(func(name): return name.match("input/*"))
		.map(func(input_name): return input_name.trim_prefix("input/"))
	)


## Updates the inspector to match
func _update_property() -> void:
	_current_input = get_edited_object()[get_edited_property()]
	for i: int in _input_options.item_count:
		if _current_input == _input_options.get_item_text(i):
			_input_options.select(i)
			return
	_input_options.select(0)
	_input_options.emit_signal("item_selected", 0)


## Sends a signal to the EditorInspector that the "input_bind" parameter should
## update to the selected value.
func _on_input_option_item_selected(index: int) -> void:
	emit_changed(get_edited_property(), _input_options.get_item_text(index))
