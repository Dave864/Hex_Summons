@tool
class_name InputLabel
extends Control
## Icon that displays an input button, either keyboard or gamepad, for a
## specific input event.
##
## Updates the displayed icon whenever the input source changes.


## Path to the icons for Sony Playstation.
const PLAYSTATION_ICON_PATH := (
	"res://user_interface/InputLabel/input_icons/playstation/"
)
## Path to the icons for Nintendo Switch.
const SWITCH_ICON_PATH := "res://user_interface/InputLabel/input_icons/switch/"
## Path to the icons for Microsoft XBox. This is used by default.
const XBOX_ICON_PATH := "res://user_interface/InputLabel/input_icons/xbox/"
## Keywords for specific controller types.
const CONTROLLER_KEYWORDS := {
	"PLAYSTATION" : ["PS", "PLAYSTATION"],
	"SWITCH" : ["SWITCH"]
}

## The source of input events. Only used for testing.
@export var input_source: InputController.Source = InputController.Source.NONE:
	set(value):
		input_source = value
		if not is_node_ready():
			return
		if Engine.is_editor_hint():
			_update_icon()
## The input event this icon is for.
@export var input_event: String = "":
	set(value):
		input_event = value
		if not is_node_ready():
			return
		_update_icon()
## The texture for the input icon.
@export var icon_texture: TextureRect = null
## The label for keyboard input.
@export var key_label: Label = null

## The base texture for keyboard inputs.
var _keyboard_icon: Texture = preload(
		"res://user_interface/InputLabel/input_icons/keyboard.tres"
)
## Object for handling RegEx expressions.
var _regex := RegEx.new()


## Connects to the InputController to enable detection of input change.
func _ready() -> void:
	InputController.connect(
			"input_source_changed",
			Callable(self, "_on_InputController_input_source_changed")
	)
	_update_icon()


## Updates the icon to display the input key for the current source.
func _update_icon() -> void:
	if Engine.is_editor_hint():
		_editor_update_icon()
		return
	if not InputMap.get_actions().has(input_event):
		_set_to_default()
	elif InputController.source_is_keymouse():
		_set_to_keyboard()
	else:
		_set_to_gamepad()


## Updates the icon to display the input key for the specified input source.
func _editor_update_icon() -> void:
	if not ProjectSettings.has_setting("input/{0}".format([input_event])):
		_set_to_default()
	elif input_source == InputController.Source.KEYBOARD_AND_MOUSE:
		_set_to_keyboard()
	elif input_source == InputController.Source.GAMEPAD:
		_set_to_gamepad()


## Sets the texture to the default Godot icon.
func _set_to_default() -> void:
	printerr("InputMap does not have event \"{0}\".".format([input_event]))
	icon_texture.stretch_mode = TextureRect.STRETCH_SCALE
	icon_texture.texture = _keyboard_icon
	key_label.text = ""
	_reset_label_size()


## Sets the texture to the keyboard icon, updating size and label to match.
func _set_to_keyboard() -> void:
	_reset_label_size()
	icon_texture.stretch_mode = TextureRect.STRETCH_SCALE
	icon_texture.texture = _keyboard_icon
	key_label.text = _get_key_event_name()


## Gets the name of the first key input for the input event. Returns an empty
## string if no key input is assigned to the event.
func _get_key_event_name() -> String:
	var input_path: String = "input/{0}".format([input_event])
	var input_events: Array = ProjectSettings.get_setting(input_path).events
	for event: InputEvent in input_events:
		if event is InputEventKey:
			return event.as_text_keycode()
	return ""


## Sets the texture to the gamepad icon, matching it to either Xbox,
## PlayStation, or Switch.
func _set_to_gamepad() -> void:
	icon_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	key_label.text = ""
	_reset_label_size()
	var icon_path := _get_controller_icon_path()
	var event_file := _get_joypad_event_file()
	if event_file == "":
		icon_texture.texture = load(Constants.DEFAULT_ICON_PATH)
	else:
		icon_texture.texture = load(icon_path + event_file)


## Gets the name of the first joypad input for the input event. Returns an
## empty string if no joypad input is assigned to the event.
func _get_joypad_event_file() -> String:
	var input_path: String = "input/{0}".format([input_event])
	var input_events: Array = ProjectSettings.get_setting(input_path).events
	for event: InputEvent in input_events:
		if event is InputEventJoypadButton:
			return _get_joypad_button_name(event)
		if event is InputEventJoypadMotion:
			return _get_joypad_motion_name(event)
	return ""


## Gets the name of the joypad button event, formatting it to be consistent with
## icon file names (button_#.tres).
func _get_joypad_button_name(button_event: InputEventJoypadButton) -> String:
	var button_name := button_event.as_text()
	_regex.compile("Button\\h\\d")
	button_name = _regex.search(button_name).get_string()
	_regex.compile("\\h")
	button_name = _regex.sub(button_name, "_", true) + ".tres"
	return button_name.to_lower()


## Gets the name of the joypad motion event, formatting it to be consistent with
## icon file names (axis_#_(+/-).tres).
func _get_joypad_motion_name(motion_event: InputEventJoypadMotion) -> String:
	var motion_name := motion_event.as_text()
	_regex.compile("Axis\\h\\d|\\h.?1\\.00")
	var results := _regex.search_all(motion_name)
	motion_name = results[0].get_string()
	motion_name += " +" if results[1].get_string().find("-") >= 0 else " -"
	_regex.compile("\\h")
	motion_name = _regex.sub(motion_name, "_", true) + ".tres"
	return motion_name


## Determines which icons to use. Uses XBox icons by default.
func _get_controller_icon_path() -> String:
	var controller_name := Input.get_joy_name(0)
	for keyword: String in CONTROLLER_KEYWORDS["PLAYSTATION"]:
		if controller_name.containsn(keyword):
			return PLAYSTATION_ICON_PATH
	for keyword: String in CONTROLLER_KEYWORDS["SWITCH"]:
		if controller_name.containsn(keyword):
			return SWITCH_ICON_PATH
	return XBOX_ICON_PATH


## Resets the key label size to the original size.
func _reset_label_size() -> void:
	key_label.set_deferred("size", key_label.get_minimum_size())
	key_label.set_deferred("offset_left", 0.0)
	key_label.set_deferred("offset_right", 0.0)
	key_label.set_deferred("offset_top", 0.0)
	key_label.set_deferred("offset_bottom", 0.0)


## Updates the icon display to match the new input source.
func _on_InputController_input_source_changed() -> void:
	_update_icon()
