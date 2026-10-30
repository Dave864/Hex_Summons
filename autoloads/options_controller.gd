extends Node
## Handles the loading and saving of game options.
##
## Manages the file saves of user settings and default values for game options.


## Indicates that the volume settings have been updated.
signal volume_updated
## Indicates that events for input actions have been updated.
signal input_updated

## Path to the user settings.
const USER_SETTINGS_PATH := "user://settings.cfg"
## Section name for volume settings.
const SECTION_VOLUME := "volume"
## Names of the primary audio buses.
const AUDIO_BUSES: PackedStringArray = [
		"Master",
		"Music",
		"Interface",
		"Effects",
]
## The default value for audio bus scale.
const DEFAULT_AUDIO_SLIDER := 1.0
## Section name for keybind settings.
const SECTION_KEYBIND := "keybind"
## Map from keypad keys to their equivalent normal keys.
const KEYPAD_TO_NORMAL_KEYS: Dictionary[Key, Key] = {
	Key.KEY_KP_0: Key.KEY_0,
	Key.KEY_KP_1: Key.KEY_1,
	Key.KEY_KP_2: Key.KEY_2,
	Key.KEY_KP_3: Key.KEY_3,
	Key.KEY_KP_4: Key.KEY_4,
	Key.KEY_KP_5: Key.KEY_5,
	Key.KEY_KP_6: Key.KEY_6,
	Key.KEY_KP_7: Key.KEY_7,
	Key.KEY_KP_8: Key.KEY_8,
	Key.KEY_KP_9: Key.KEY_9,
	Key.KEY_KP_ADD: Key.KEY_PLUS,
	Key.KEY_KP_SUBTRACT: Key.KEY_MINUS,
	Key.KEY_KP_MULTIPLY: Key.KEY_ASTERISK,
	Key.KEY_KP_DIVIDE: Key.KEY_SLASH,
	Key.KEY_KP_ENTER: Key.KEY_ENTER,
	Key.KEY_KP_PERIOD: Key.KEY_PERIOD,
}
## Map for keys that have keypad equivalents.
const NORMAL_TO_KEYPAD_KEYS: Dictionary[Key, Key] = {
	Key.KEY_0: Key.KEY_KP_0,
	Key.KEY_1: Key.KEY_KP_1,
	Key.KEY_2: Key.KEY_KP_2,
	Key.KEY_3: Key.KEY_KP_3,
	Key.KEY_4: Key.KEY_KP_4,
	Key.KEY_5: Key.KEY_KP_5,
	Key.KEY_6: Key.KEY_KP_6,
	Key.KEY_7: Key.KEY_KP_7,
	Key.KEY_8: Key.KEY_KP_8,
	Key.KEY_9: Key.KEY_KP_9,
	Key.KEY_PLUS: Key.KEY_KP_ADD,
	Key.KEY_MINUS: Key.KEY_KP_SUBTRACT,
	Key.KEY_ASTERISK: Key.KEY_KP_MULTIPLY,
	Key.KEY_SLASH: Key.KEY_KP_DIVIDE,
	Key.KEY_ENTER: Key.KEY_KP_ENTER,
	Key.KEY_PERIOD: Key.KEY_KP_PERIOD,
}
## Map to shorthand for various event key text.
const INPUT_KEY_SHORTHAND := {
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

## Helper for managing user settings.
var _config_file: ConfigFile

## The default values for input keybinds.
@onready var _default_keybinds: DefaultKeybinds = preload(
		"res://user_interface/Options/controls/default_keybinds.tres"
)


## Initializes the settings to custom user values if any have been defined.
## Otherwise sets everything to default.
func _ready() -> void:
	_config_file = ConfigFile.new()
	if FileAccess.file_exists(USER_SETTINGS_PATH):
		if Error.OK == _config_file.load(USER_SETTINGS_PATH):
			load_custom_volumes()
			load_custom_keybinds()
			return
	else:
		_create_user_file()
	load_default_volumes()
	load_default_keybinds()


## Gets the shorthand for the given key text. Returns the original text if no
## shorthand exists.
func get_input_key_shorthand(input_key: String) -> String:
	if INPUT_KEY_SHORTHAND.has(input_key):
		return INPUT_KEY_SHORTHAND[input_key]
	return input_key


## Takes the current key and determines either the equivalent keypad button or
## keyboard button. 
func get_input_for_keypad(input: InputEventKey) -> InputEventKey:
	var input_equivalent: InputEventKey = null
	if KEYPAD_TO_NORMAL_KEYS.has(input.keycode):
		input_equivalent = InputEventKey.new()
		input_equivalent.keycode = KEYPAD_TO_NORMAL_KEYS[input.keycode]
	elif NORMAL_TO_KEYPAD_KEYS.has(input.keycode):
		input_equivalent = InputEventKey.new()
		input_equivalent.keycode = NORMAL_TO_KEYPAD_KEYS[input.keycode]
	return input_equivalent


## Updates the audio buses to use the default settings. Also saves the default
## values to user file.
func load_default_volumes() -> void:
	for audio_bus: String in AUDIO_BUSES:
		var index: int = _get_audio_bus_index(audio_bus)
		if index < 0:
			continue
		_config_file.set_value(SECTION_VOLUME, audio_bus, DEFAULT_AUDIO_SLIDER)
		AudioServer.set_bus_volume_db(index, linear_to_db(DEFAULT_AUDIO_SLIDER))
	_save_config()
	volume_updated.emit()


## Updates the audio buses to use custom user settings.
func load_custom_volumes() -> void:
	if not _config_file.has_section(SECTION_VOLUME):
		load_default_volumes()
		return
	for audio_bus: String in AUDIO_BUSES:
		var index: int = _get_audio_bus_index(audio_bus)
		if index < 0:
			continue
		var slider_value: float = _config_file.get_value(
				SECTION_VOLUME,
				audio_bus
		)
		AudioServer.set_bus_volume_db(index, linear_to_db(slider_value))
	volume_updated.emit()


## Saves current volume values to user file.
func save_custom_volumes_to_file(
	volume_scales: Dictionary[String, float]
) -> void:
	for audio_bus: String in volume_scales.keys():
		var index: int = _get_audio_bus_index(audio_bus)
		if index < 0:
			continue
		_config_file.set_value(
				SECTION_VOLUME,
				audio_bus,
				volume_scales[audio_bus]
		)
	_save_config()
	load_custom_volumes()


## Updates the input map to use default keybind settings. Also saves the default
## settings to user file.
func load_default_keybinds() -> void:
	var keybinds := _default_keybinds.get_all_keybinds()
	for action: String in keybinds.keys():
		InputMap.action_erase_events(action)
		# Need to add on additional inputs for events that have matching keypad
		# action and vice-versa. Is a copy to prevent infinite loop when
		# checking for keypad action.
		var events := keybinds[action].duplicate()
		for event: InputEvent in keybinds[action]:
			InputMap.action_add_event(action, event)
			if event is InputEventKey:
				var kp_event := get_input_for_keypad(event)
				if kp_event != null:
					InputMap.action_add_event(action, kp_event)
					events.append(kp_event)
		_config_file.set_value(SECTION_KEYBIND, action, events)
	_save_config()
	input_updated.emit()


## Updates the input map to use saved custom keybind settings.
func load_custom_keybinds() -> void:
	if not _config_file.has_section(SECTION_KEYBIND):
		load_default_keybinds()
		return
	var input_actions := _config_file.get_section_keys(SECTION_KEYBIND)
	for action: String in input_actions:
		InputMap.action_erase_events(action)
		var input_events: Array = _config_file.get_value(
				SECTION_KEYBIND,
				action
		)
		for event: InputEvent in input_events:
			InputMap.action_add_event(action, event)
	input_updated.emit()


## Saves the current keybinds to user file, updating the input map to reflect
## the changes.
func save_custom_keybinds_to_file(keybinds: Dictionary[String, Array]) -> void:
	for input_event: String in keybinds.keys():
		var input_binds: Array[InputEvent] = keybinds[input_event]
		_config_file.set_value(SECTION_KEYBIND, input_event, input_binds)
	_save_config()
	load_custom_keybinds()


## Gets the index of the specified audio bus, checking if it exists.
func _get_audio_bus_index(audio_bus: String) -> int:
	var index: int = AudioServer.get_bus_index(audio_bus)
	if index < 0:
		printerr("There is no audio bus named {0}.".format([audio_bus]))
	return index


## Creates a new configuration file.
func _create_user_file() -> void:
	for audio_bus: String in AUDIO_BUSES:
		_config_file.set_value(SECTION_VOLUME, audio_bus, DEFAULT_AUDIO_SLIDER)
	for action: String in _default_keybinds.get_input_actions():
		_config_file.set_value(SECTION_KEYBIND, action, [])


## Saves the current configuration settings.
func _save_config() -> void:
	if Error.OK != _config_file.save(USER_SETTINGS_PATH):
		printerr("Failed to save user settings.")
