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

## The input event this icon is for.
@export var input_event: String = ""

## The base texture for keyboard inputs.
var _keyboard_icon: Texture = preload(
		"res://user_interface/InputLabel/input_icons/keyboard.tres"
)

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
	if not InputMap.get_actions().has(input_event):
		_set_to_default()
	if InputController.source_is_keymouse():
		pass
	else:
		pass


## Sets the texture to the default Godot icon.
func _set_to_default() -> void:
	printerr("Tracked input event {0} does not exist.".format([input_event]))
	texture = load(Constants.DEFAULT_ICON_PATH)


## Updates the icon display to match the new input source.
func _on_InputController_input_source_changed() -> void:
	_update_icon()
