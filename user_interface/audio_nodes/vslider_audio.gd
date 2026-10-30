class_name VSliderAudio
extends VSlider
## Vertical slider that can play specified sounds for specific actions.


@export_group("Audio Tracks", "asp_")
## The audio stream for "changed".
@export var asp_changed: AudioStreamPlayer = null
## The audio stream for "value_changed".
@export var asp_value_changed: AudioStreamPlayer = null
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
	changed.connect(_on_VSliderAudio_changed)
	value_changed.connect(_on_VSliderAudio_value_changed)
	focus_entered.connect(_on_VSliderAudio_focus_entered)
	focus_exited.connect(_on_VSliderAudio_focus_exited)
	gui_input.connect(_on_VSliderAudio_gui_input)
	mouse_entered.connect(_on_VSliderAudio_mouse_entered)
	mouse_exited.connect(_on_VSliderAudio_mouse_exited)


## Plays the specified sound if present.
func _play_sound(audio_stream: AudioStreamPlayer) -> void:
	if audio_stream != null:
		audio_stream.play()


## Plays the sound assigned to "on_changed". Does nothing if no sound is
## assigned.
func _on_VSliderAudio_changed() -> void:
	_play_sound(asp_changed)


## Plays the sound assigned to "value_changed". Does nothing if no sound is
## assigned.
func _on_VSliderAudio_value_changed(_value: float) -> void:
	_play_sound(asp_value_changed)


## Plays the sound assigned to "focus_entered". Does nothing if no sound is
## assigned.
func _on_VSliderAudio_focus_entered() -> void:
	_play_sound(asp_focus_entered)


## Plays the sound assigned to "focus_exited". Does nothing if no sound is
## assigned.
func _on_VSliderAudio_focus_exited() -> void:
	_play_sound(asp_focus_exited)


## Plays the sound assigned to "gui_input". Does nothing if no sound is
## assigned.
func _on_VSliderAudio_gui_input(_event: InputEvent) -> void:
	_play_sound(asp_gui_input)


## Plays the sound assigned to "mouse_entered". Does nothing if no sound is
## assigned.
func _on_VSliderAudio_mouse_entered() -> void:
	_play_sound(asp_mouse_entered)


## Plays the sound assigned to "mouse_exited". Does nothing if no sound is
## assigned.
func _on_VSliderAudio_mouse_exited() -> void:
	_play_sound(asp_mouse_exited)
