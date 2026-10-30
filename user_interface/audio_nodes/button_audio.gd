class_name ButtonAudio
extends Button
## Button that allows for the specifying of sound effects for different actions.


@export_group("Audio Tracks", "asp_")
## The audio stream for "button_down".
@export var asp_button_down: AudioStreamPlayer = null
## The audio stream for "button_up".
@export var asp_button_up: AudioStreamPlayer = null
## The audio stream for "pressed".
@export var asp_pressed: AudioStreamPlayer = null 
## The audio stream for "toggled" on.
@export var asp_toggle_on: AudioStreamPlayer = null
## The audio stream for "toggled" off.
@export var asp_toggle_off: AudioStreamPlayer = null
## The audio stream for "focus_entered".
@export var asp_focus_entered: AudioStreamPlayer = null
## The audio stream for "focus_exited".
@export var asp_focus_exited: AudioStreamPlayer = null
## The audio stream for "gui_input".
@export var asp_gui_input: AudioStreamPlayer = null
## The audio stream for "mouse_entered".
@export var asp_mouse_entered: AudioStreamPlayer = null
## The audio stream for "mouse_exited".
@export var asp_mouse_exited: AudioStreamPlayer = null


## Connects the relevant signals to play sound.
func _ready() -> void:
	button_down.connect(_on_ButtonAudio_button_down)
	button_up.connect(_on_ButtonAudio_button_up)
	pressed.connect(_on_ButtonAudio_pressed)
	toggled.connect(_on_ButtonAudio_toggled)
	focus_entered.connect(_on_ButtonAudio_focus_entered)
	focus_exited.connect(_on_ButtonAudio_focus_exited)
	gui_input.connect(_on_ButtonAudio_gui_input)
	mouse_entered.connect(_on_ButtonAudio_mouse_entered)
	mouse_exited.connect(_on_ButtonAudio_mouse_exited)


## Plays the specified sound if present.
func _play_sound(audio_stream: AudioStreamPlayer) -> void:
	if audio_stream != null:
		audio_stream.play()


## Plays the sound assigned to "button_down". Does nothing if no sound is
## assigned.
func _on_ButtonAudio_button_down() -> void:
	_play_sound(asp_button_down)


## Plays the sound assigned to "button_up". Does nothing if no sound is
## assigned.
func _on_ButtonAudio_button_up() -> void:
	_play_sound(asp_button_up)


## Plays the sound assigned to "pressed". Does nothing if no sound is assigned.
func _on_ButtonAudio_pressed() -> void:
	_play_sound(asp_pressed)


## Plays the sound assigned to "toggled". Can play different sounds for toggled
## on and toggled off. Does nothing if no sound is assigned.
func _on_ButtonAudio_toggled(toggled_on: bool) -> void:
	if toggled_on:
		_play_sound(asp_toggle_on)
	else:
		_play_sound(asp_toggle_off)


## Plays the sound assigned to "focus_entered". Does nothing if no sound is
## assigned.
func _on_ButtonAudio_focus_entered() -> void:
	_play_sound(asp_focus_entered)


## Plays the sound assigned to "focus_exited". Does nothing if no sound is
## assigned.
func _on_ButtonAudio_focus_exited() -> void:
	_play_sound(asp_focus_exited)


## Plays the sound assigned to "gui_input". Does nothing if no sound is
## assigned.
func _on_ButtonAudio_gui_input(_event: InputEvent) -> void:
	_play_sound(asp_gui_input)


## Plays the sound assigned to "mouse_entered". Does nothing if no sound is
## assigned.
func _on_ButtonAudio_mouse_entered() -> void:
	_play_sound(asp_mouse_entered)


## Plays the sound assigned to "mouse_exited". Does nothing if no sound is
## assigned.
func _on_ButtonAudio_mouse_exited() -> void:
	_play_sound(asp_mouse_exited)
