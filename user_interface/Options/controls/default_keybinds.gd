class_name DefaultKeybinds
extends Resource
## Records the default keybinds for various input events.


@export_group("Keymouse Events", "keymouse_")
@export_subgroup("UI", "keymouse_ui")
## Keyboard and mouse input for "ui_accept" event.
@export var keymouse_ui_accept: InputEventKey = null
## Keyboard and mouse input for "ui_cancel" event.
@export var keymouse_ui_cancel: InputEventKey = null
## Keyboard and mouse input for "ui_left" event.
@export var keymouse_ui_left: InputEventKey = null
## Keyboard and mouse input for "ui_right" event.
@export var keymouse_ui_right: InputEventKey = null
## Keyboard and mouse input for "ui_up" event.
@export var keymouse_ui_up: InputEventKey = null
## Keyboard and mouse input for "ui_down" event.
@export var keymouse_ui_down: InputEventKey = null
## Keyboard and mouse input for "ui_selector_select" event.
@export var keymouse_ui_selector_select: InputEventMouseButton = null
## Keyboard and mouse input for "ui_encounter_movement" event.
@export var keymouse_ui_encounter_movement: InputEventKey = null
## Keyboard and mouse input for "ui_encounter_option_1" event.
@export var keymouse_ui_encounter_option_1: InputEventKey = null
## Keyboard and mouse input for "ui_encounter_option_2" event.
@export var keymouse_ui_encounter_option_2: InputEventKey = null
## Keyboard and mouse input for "ui_encounter_option_3" event.
@export var keymouse_ui_encounter_option_3: InputEventKey = null
## Keyboard and mouse input for "ui_encounter_option_4" event.
@export var keymouse_ui_encounter_option_4: InputEventKey = null
## Keyboard and mouse input for "ui_encounter_player_end" event.
@export var keymouse_ui_encounter_player_end: InputEventKey = null
## Keyboard and mouse input for "ui_camera_reset" event.
@export var keymouse_ui_camera_reset: InputEventMouseButton = null
## Keyboard and mouse input for "ui_camera_pan" event.
@export var keymouse_ui_camera_pan: InputEventMouseButton = null
@export_subgroup("Player Movement", "keymouse_player_move_")
## Keyboard and mouse input for "player_move_l" event.
@export var keymouse_player_move_l: InputEventKey = null
## Keyboard and mouse input for "player_move_r" event.
@export var keymouse_player_move_r: InputEventKey = null
## Keyboard and mouse input for "player_move_u" event.
@export var keymouse_player_move_u: InputEventKey = null
## Keyboard and mouse input for "player_move_d" event.
@export var keymouse_player_move_d: InputEventKey = null

@export_group("Gamepad Events", "gamepad_")
@export_subgroup("UI", "gamepad_ui")
## Gamepad input for "ui_accept" event.
@export var gamepad_ui_accept: InputEventJoypadButton = null
## Gamepad input for "ui_cancel" event.
@export var gamepad_ui_cancel: InputEventJoypadButton = null
## Gamepad input for "ui_left" event.
@export var gamepad_ui_left: InputEventJoypadButton = null
## Gamepad input for "ui_right" event.
@export var gamepad_ui_right: InputEventJoypadButton = null
## Gamepad input for "ui_up" event.
@export var gamepad_ui_up: InputEventJoypadButton = null
## Gamepad input for "ui_down" event.
@export var gamepad_ui_down: InputEventJoypadButton = null
## Gamepad input for "ui_selector_select" event.
@export var gamepad_ui_selector_select: InputEventJoypadButton = null
## Gamepad input for "ui_encounter_movement" event.
@export var gamepad_ui_encounter_movement: InputEventJoypadButton = null
## Gamepad input for "ui_encounter_option_1" event.
@export var gamepad_ui_encounter_option_1: InputEventJoypadButton = null
## Gamepad input for "ui_encounter_option_2" event.
@export var gamepad_ui_encounter_option_2: InputEventJoypadButton = null
## Gamepad input for "ui_encounter_option_3" event.
@export var gamepad_ui_encounter_option_3: InputEventJoypadButton = null
## Gamepad input for "ui_encounter_option_4" event.
@export var gamepad_ui_encounter_option_4: InputEventJoypadButton = null
## Gamepad input for "ui_encounter_player_end" event.
@export var gamepad_ui_encounter_player_end: InputEventJoypadButton = null
## Gamepad input for "ui_camera_reset" event.
@export var gamepad_ui_camera_reset: InputEventJoypadButton = null
@export_subgroup("Left Joystick", "gamepad_left_joystick_")
## Gamepad input for "left_joystick_l" event.
@export var gamepad_left_joystick_l: InputEventJoypadMotion = null
## Gamepad input for "left_joystick_r" event.
@export var gamepad_left_joystick_r: InputEventJoypadMotion = null
## Gamepad input for "left_joystick_u" event.
@export var gamepad_left_joystick_u: InputEventJoypadMotion = null
## Gamepad input for "left_joystick_d" event.
@export var gamepad_left_joystick_d: InputEventJoypadMotion = null
@export_subgroup("Right Joystick", "gamepad_right_joystick_")
## Gamepad input for "right_joystick_l" event.
@export var gamepad_right_joystick_l: InputEventJoypadMotion = null
## Gamepad input for "right_joystick_r" event.
@export var gamepad_right_joystick_r: InputEventJoypadMotion = null
## Gamepad input for "right_joystick_u" event.
@export var gamepad_right_joystick_u: InputEventJoypadMotion = null
## Gamepad input for "right_joystick_d" event.
@export var gamepad_right_joystick_d: InputEventJoypadMotion = null
