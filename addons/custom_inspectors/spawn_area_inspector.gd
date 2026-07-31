class_name SpawnAreaInspector
extends EditorInspectorPlugin


func _can_handle(object: Object) -> bool:
	if object is SpawnArea:
		return true
	return false


func _parse_property(
	object: Object,
	type: Variant.Type,
	name: String,
	hint_type: PropertyHint,
	hint_string: String,
	usage_flags: int,
	wide: bool
) -> bool:
	if name == "enemies":
		add_property_editor(name, SpawnAreaEnemiesProperty.new())
		return true
	return false
