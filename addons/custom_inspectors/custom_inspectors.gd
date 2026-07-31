@tool
extends EditorPlugin


const SPAWN_AREA_INSPECTOR = preload(
		"res://addons/custom_inspectors/spawn_area_inspector.gd"
)

var spawn_area_inspector: SpawnAreaInspector


func _enter_tree() -> void:
	spawn_area_inspector = SpawnAreaInspector.new()
	add_inspector_plugin(spawn_area_inspector)


func _exit_tree() -> void:
	if spawn_area_inspector:
		remove_inspector_plugin(spawn_area_inspector)
