@tool
extends EditorPlugin
## Custom inspectors for various HexSummons project scripts.


## Custom inspector for SpawnArea.
var spawn_area_inspector: SpawnAreaInspector
## Custom inspector for KeybindInputButton.
var keybind_input_button_inspector: KeybindInputButtonInspector


## Add all the custom inspectors.
func _enter_tree() -> void:
	spawn_area_inspector = SpawnAreaInspector.new()
	keybind_input_button_inspector = KeybindInputButtonInspector.new()
	add_inspector_plugin(spawn_area_inspector)
	add_inspector_plugin(keybind_input_button_inspector)


## Remove all the custom inspectors.
func _exit_tree() -> void:
	if spawn_area_inspector:
		remove_inspector_plugin(spawn_area_inspector)
	if keybind_input_button_inspector:
		remove_inspector_plugin(keybind_input_button_inspector)
