class_name SpawnAreaInspector
extends EditorInspectorPlugin
## Custom inspector for relevant parameters of SpawnArea.
##
## Defines inspectors for the "enemis" parameter.


## Checks that the object should be handled by this plugin.
func _can_handle(object: Object) -> bool:
	return object is SpawnArea


## Replaces the default inspector handlers in SpawnArea for any custom ones
## should they exist.
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
