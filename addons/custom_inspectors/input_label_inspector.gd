class_name InputLabelInspector
extends EditorInspectorPlugin
## Custom inspector for relevant parameters of InputLabel.
##
## Defines inspector for "input_event" parameter.


## Checks that the object should be handled by this plugin.
func _can_handle(object: Object) -> bool:
	return object is InputLabel


## Replaces the default inspector handlers in InputLabel for any custom ones
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
	if name == "input_event":
		add_property_editor(name, InputOptionProperty.new())
		return true
	return false
