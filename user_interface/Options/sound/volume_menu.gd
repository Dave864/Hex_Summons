class_name VolumeControl
extends Control
## Menu that handles the setting of audio bus volumes.
##
## Manages the saving of current volume settings and the loading of default ones.
## Initial volume levels are set in OptionsController.


## Slider for master audio bus volume.
@onready var master_slider: VolumeSlider = (
		$VolumeContainer/MasterVolumeContainer/MasterSlider
)
## Slider for music audio bus volume.
@onready var music_slider: VolumeSlider = (
		$VolumeContainer/SubVolumeContainer/SlidersContainer/MusicSlider
)
## Slider for interface audio bus volume.
@onready var interface_slider: VolumeSlider = (
		$VolumeContainer/SubVolumeContainer/SlidersContainer/InterfaceSlider
)
## Slider for effects audio bus volume.
@onready var effects_slider: VolumeSlider = (
		$VolumeContainer/SubVolumeContainer/SlidersContainer/EffectsSlider
)


## Sets the sliders to reflect the audio bus levels and record initial volumes.
func _ready() -> void:
	OptionsController.volume_updated.connect(
			_on_OptionsController_volume_updated
	)


## Updates the volume sliders to matcht the current user settings.
func _on_OptionsController_volume_updated() -> void:
	master_slider.match_slider_to_audio_bus()
	music_slider.match_slider_to_audio_bus()
	interface_slider.match_slider_to_audio_bus()
	effects_slider.match_slider_to_audio_bus()
	master_slider.reset_initial_value()
	music_slider.reset_initial_value()
	interface_slider.reset_initial_value()
	effects_slider.reset_initial_value()


## Updates the user settings to match the currently set volumes.
func _on_confirm_button_pressed() -> void:
	var volume_data: Dictionary[String, float] = {
		OptionsController.AUDIO_BUSES[0]: master_slider.value,
		OptionsController.AUDIO_BUSES[1]: music_slider.value,
		OptionsController.AUDIO_BUSES[2]: interface_slider.value,
		OptionsController.AUDIO_BUSES[3]: effects_slider.value
	}
	OptionsController.save_custom_volumes_to_file(volume_data)


## Resets the user settings to the default volume settings.
func _on_reset_button_pressed() -> void:
	OptionsController.load_default_volumes()
