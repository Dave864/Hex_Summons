extends Node
## Handles the loading and saving of game options.
##
## Manages the file saves of user settings and default values for game options.


## Initializes the settings to custom user values if any have been defined.
## Otherwise, sets everything to default.
func _ready() -> void:
	pass


## Updates the audio buses to use the default settings. Also saves the default
## values to user file.
func load_default_volumes() -> void:
	pass


## Saves current volume values to user file.
func save_custom_volumes_to_file() -> void:
	pass


## Updates the input map to use default keybind settings. Also saves the default
## settings to user file.
func load_default_keybinds() -> void:
	pass


## Saves the current keybinds to user file.
func save_custom_keybinds_to_file() -> void:
	pass
