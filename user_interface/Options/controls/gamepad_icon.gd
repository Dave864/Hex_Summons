class_name GamepadIcon
extends TextureRect
## Icon that displays an icon for some gamepad input.
##
## Supports XBox, Playstation, and Nintendo Switch. Works similarly to InputLabel's
## gamepad logic.


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
	"PLAYSTATION" : ["PS", "PLAYSTATION", "DUALSENSE"],
	"SWITCH" : ["SWITCH"],
}

## Object for handling RegEx expressions.
var _regex := RegEx.new()


## Initializes the settings for this icon.
func _init() -> void:
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	name = "GamepadIcon"


## Updates the icon to match the provided input event. Sets the texture to null
## if there is none for the event or if the event is not for gamepad.
func update_for_event(event: InputEvent) -> void:
	var event_file: String
	if event is InputEventJoypadButton:
		event_file = _get_joypad_button_name(event)
	elif event is InputEventJoypadMotion:
		event_file = _get_joypad_motion_name(event)
	else:
		event_file = ""
	if event_file == "":
		texture = null
	else:
		var icon_path := _get_controller_icon_path()
		texture = load(icon_path + event_file)


## Gets the name of the joypad button event, formatting it to be consistent with
## icon file names (button_#.tres).
func _get_joypad_button_name(button_event: InputEventJoypadButton) -> String:
	var button_name := button_event.as_text()
	_regex.compile("Button\\h\\d+")
	button_name = _regex.search(button_name).get_string()
	_regex.compile("\\h")
	button_name = _regex.sub(button_name, "_", true) + ".tres"
	return button_name.to_lower()


## Gets the name of the joypad motion event, formatting it to be consistent with
## icon file names (axis_#_(+/-).tres).
func _get_joypad_motion_name(motion_event: InputEventJoypadMotion) -> String:
	var motion_name := motion_event.as_text()
	_regex.compile("Axis\\h\\d|\\h.?\\d\\.\\d\\d")
	var results := _regex.search_all(motion_name)
	motion_name = results[0].get_string()
	motion_name += " +" if results[1].get_string().find("-") >= 0 else " -"
	_regex.compile("\\h")
	motion_name = _regex.sub(motion_name, "_", true) + ".tres"
	return motion_name.to_lower()


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
