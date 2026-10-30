class_name  TabContainerAudio
extends TabContainer
## TabContainer that allows for the specifying of sound effects for different
## actions.


@export_group("Audio Tracks", "asp_")
## The audio stream for "tab_changed".
@export var asp_tab_changed: AudioStreamPlayer = null
## The audio stream for "tab_clicked".
@export var asp_tab_clicked: AudioStreamPlayer = null
## The audio stream for "tab_hovered".
@export var asp_tab_hovered: AudioStreamPlayer = null
## The audio stream for "tab_selected".
@export var asp_tab_selected: AudioStreamPlayer = null
## The audio stream for "focus_entered".
@export var asp_focus_entered: AudioStreamPlayer = null


## Connects the relevant signals to play sound.
func _ready() -> void:
	tab_changed.connect(_on_TabContainerAudio_tab_changed)
	tab_clicked.connect(_on_TabContainerAudio_tab_clicked)
	tab_hovered.connect(_on_TabContainerAudio_tab_hovered)
	tab_selected.connect(_on_TabContainerAudio_tab_selected)
	get_tab_bar().focus_entered.connect(_on_TabContainerAudio_focus_entered)


## Plays the specified sound if present.
func _play_sound(audio_stream: AudioStreamPlayer) -> void:
	if audio_stream != null:
		audio_stream.play()


## Plays the sound assigned to "tab_changed". Does nothing if no sound is
## assigned.
func _on_TabContainerAudio_tab_changed(_tab: int) -> void:
	_play_sound(asp_tab_changed)


## Plays the sound assigned to "tab_clicked". Does nothing if no sound is
## assigned.
func _on_TabContainerAudio_tab_clicked(_tab: int) -> void:
	_play_sound(asp_tab_clicked)


## Plays the sound assigned to "tab_hovered". Does nothing if no sound is
## assigned.
func _on_TabContainerAudio_tab_hovered(_tab: int) -> void:
	_play_sound(asp_tab_hovered)


## Plays the sound assigned to "tab_selected". Does nothing if no sound is
## assigned.
func _on_TabContainerAudio_tab_selected(_tab: int) -> void:
	_play_sound(asp_tab_selected)


## Plays the sound assigned to "focus_entered". Does nothing if no sound is
## assigned.
func _on_TabContainerAudio_focus_entered() -> void:
	_play_sound(asp_focus_entered)
