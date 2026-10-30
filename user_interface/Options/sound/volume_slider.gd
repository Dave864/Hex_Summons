class_name VolumeSlider
extends HSliderAudio
## Slider that handles the defining of volume settings for a specific audio
## bus.
##
## Able to specify the audio bus that is to be adjusted. Audio bus settings are
## changed as slider moves. Does not automatically save settings when adjusting
## slider.


## The max value of the slider.
const SLIDER_MAX := 1.0
## The step value of the slider.
const SLIDER_STEP := 0.02

## The name of the audio bus that is updated.
@export_enum(
		OptionsController.AUDIO_BUSES[0],
		OptionsController.AUDIO_BUSES[1],
		OptionsController.AUDIO_BUSES[2],
		OptionsController.AUDIO_BUSES[3],
) var audio_bus: String = OptionsController.AUDIO_BUSES[0]
## The debounce timer used to delay the playing of value changed sound when
## constantly shifting the slider value.
@export var debounce_timer: Timer = null

## The index of the audio bus.
var _bus_index: int = -1
## The initial slider value.
var _initial_value := 0.0

## Icon that indicates that the value has changed from initial.
@onready var _changed_icon: ActiveIcon = $ActiveIcon


## Initializes slider range and initial position.
func _ready() -> void:
	super._ready()
	value_changed.connect(_on_value_changed)
	max_value = SLIDER_MAX
	min_value = 0.0
	step = SLIDER_STEP
	_bus_index = AudioServer.get_bus_index(audio_bus)
	match_slider_to_audio_bus()
	_initial_value = value
	_changed_icon.is_active = false


## Sets the slider to match the volume of the observed audio bus.
func match_slider_to_audio_bus() -> void:
	if not _audio_bus_present():
		return
	set_value_no_signal(db_to_linear(AudioServer.get_bus_volume_db(_bus_index)))


## Sets the value to the initial value.
func set_value_to_initial() -> void:
	set_value_no_signal(_initial_value)
	_changed_icon.is_active = false


## Updates the initial value to match the current value.
func reset_initial_value() -> void:
	_initial_value = value
	_changed_icon.is_active = false


## Checks if the specified audio bus exists.
func _audio_bus_present() -> bool:
	if _bus_index < 0:
		value = 0.0
		printerr("There is no audio bus named {0}.".format([audio_bus]))
		return false
	return true


## Updates the sound of the audio bus to reflect the slider value. Updates
## changed icon to indicate a change.
func _on_value_changed(new_value: float) -> void:
	if not _audio_bus_present():
		return
	AudioServer.set_bus_volume_db(_bus_index, linear_to_db(new_value))
	_changed_icon.is_active = not is_equal_approx(new_value, _initial_value)


## Plays a sound when changing the slider value. Does not play the sound
## if the timer is active.
func _on_HSliderAudio_value_changed(new_value: float) -> void:
	if debounce_timer.is_stopped():
		super._on_HSliderAudio_value_changed(new_value)
		debounce_timer.start()
