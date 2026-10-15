class_name KeybindInputButtonInspector
extends EditorInspectorPlugin
## Custom inspector for relevant parameters of KeybindInputButton.
##
## Defines inspector for "input_bind" parameter.


## Checks that the object should be handled by this plugin.
func _can_handle(object: Object) -> bool:
	return object is KeybindInputButton


## Replaces the default inspector handlers in KeybindInputButton for any custom
## ones should they exist.
func _parse_property(
	object: Object,
	type: Variant.Type,
	name: String,
	hint_type: PropertyHint,
	hint_string: String,
	usage_flags: int,
	wide: bool
) -> bool:
	if name == "input_bind":
		add_property_editor(name, KeybindInputButtonInputBindProperty.new())
		return true
	return false
