@tool
class_name InputLabel
extends TextureRect
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
## Path to the icons for Microsoft XBox.
const XBOX_ICON_PATH := "res://user_interface/InputLabel/input_icons/xbox/"

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

## The base texture for keyboard inputs.
var _keyboard_icon: Texture = preload(
		"res://user_interface/InputLabel/input_icons/keyboard.tres"
)

## The label for keyboard input icon.
@onready var _keyboard_label: Label = $KeyboardLabel
## The original size dimensions of the icon.
@onready var _original_size: Vector2 = size


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
	stretch_mode = TextureRect.STRETCH_SCALE
	texture = load(Constants.DEFAULT_ICON_PATH)


## Sets the texture to the keyboard icon, updating size and label to match.
func _set_to_keyboard() -> void:
	stretch_mode = TextureRect.STRETCH_SCALE
	texture = _keyboard_icon
	_keyboard_label.text = _get_key_name()


## Gets the name of the first key input for the input event. Returns an empty
## string if no key input is assigned to the event.
func _get_key_name() -> String:
	var input_path: String = "input/{0}".format([input_event])
	var input_events: Array = ProjectSettings.get_setting(input_path).events
	for event: InputEvent in input_events:
		if event is InputEventKey:
			return event.as_text_keycode()
	return ""


## Sets the texture to the gamepad icon, matching it to either Xbox,
## PlayStation, or Switch.
func _set_to_gamepad() -> void:
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	size = _original_size
	_keyboard_label.text = ""


## Updates the icon display to match the new input source.
func _on_InputController_input_source_changed() -> void:
	_update_icon()
