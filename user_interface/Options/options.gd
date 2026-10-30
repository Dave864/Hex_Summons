class_name Options
extends Control
## Manages opening and closing of options menu.
##
## Sets initial focus when opened. Does not actually close the menu, but emits
## a signal indicating that it should be closed.


@export_group("Audio Tracks", "asp_")
## Audio stream for when this menu is opened.
@export var asp_open: AudioStreamPlayer = null
## Audio stream for when this menu is closed.
@export var asp_closed: AudioStreamPlayer = null

## Indicates that this menu is to be closed.
signal closed

## Flag that indicates that this menu is open.
var is_open := false

## The tab menu for the options.
@onready var menu: TabContainer = $TabContainer


## Checks if the menu should be closed.
func _input(event: InputEvent) -> void:
	if not is_open:
		return
	if event.is_action("ui_cancel"):
		closed.emit()
		_play_sound(asp_closed)
		is_open = false


## Sets the focus to the first tab in the menu
func open() -> void:
	is_open = true
	menu.current_tab = 0
	menu.get_tab_bar().grab_focus()
	_play_sound(asp_open)


## Plays the specified sound if present.
func _play_sound(audio_stream: AudioStreamPlayer) -> void:
	if audio_stream != null:
		audio_stream.play()
