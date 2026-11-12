class_name Credits
extends Control
## Page that displays the credits for the game.
##
## Sets the focus to the scroll bar if present. Does not actually close the
## page, but emits a signal indicating that it should be closed.


## The label with the credits text.
@export var credits_text: RichTextLabel = null
@export_group("Audio Tracks", "asp_")
## Audio stream for when this menu is opened.
@export var asp_open: AudioStreamPlayer = null
## Audio stream for when this menu is closed.
@export var asp_closed: AudioStreamPlayer = null

## Indicates that this page is to be closed.
signal closed

## Flag that indicates that this page is open.
var is_open := false

## Scrollbar for the text.
@onready var _scroll_bar: VScrollBar = credits_text.get_v_scroll_bar()


## Initializes the step values for the scroll bar.
func _ready() -> void:
	_scroll_bar.custom_step = 10.0
	_scroll_bar.connect("focus_exited", _on_VScrollBar_focus_exited)


## Checks if the page should be closed.
func _input(event: InputEvent) -> void:
	if not is_open:
		return
	if event.is_action("ui_cancel"):
		is_open = false
		# Defer emission of closed signal to prevent scroll bar from getting
		# focus back from the currently active menu.
		closed.emit.call_deferred()
		_play_sound(asp_closed)


## Sets the focus to the scroll bar.
func open() -> void:
	is_open = true
	_play_sound(asp_open)
	_scroll_bar.value = 0.0
	_scroll_bar.grab_focus.call_deferred()


## Plays the specified sound if present.
func _play_sound(audio_stream: AudioStreamPlayer) -> void:
	if audio_stream != null:
		audio_stream.play()


## Opens the link that was clicked on in the credits text.
func _on_credits_text_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))


## Returns focus bas to scrollbar if it is lost while the page is open.
func _on_VScrollBar_focus_exited() -> void:
	if is_open:
		_scroll_bar.grab_focus.call_deferred()
