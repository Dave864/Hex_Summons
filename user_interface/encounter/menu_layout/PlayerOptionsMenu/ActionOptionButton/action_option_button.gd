class_name ActionOptionButton
extends Button
## A button that represents an option for a given action type.
##
## Tracks the action that this button is for. Passes along the action data when
## this button is pressed.


## Indicates that the action this button represents has been highlighted.
signal action_highlighted(action)
## Indicates that the action this button represents has been selected.
signal action_selected(action)

## The action this button represents.
var _action: Action = null


## Creates a button with the provided action.
func _init(stored_action: Action) -> void:
	_action = stored_action
	name = _action.name
	text = name
	alignment = HORIZONTAL_ALIGNMENT_CENTER
	flat = true
	connect("pressed", Callable(self, "_on_ActionOptionButton_pressed"))
	connect(
			"focus_entered",
			Callable(self, "_on_ActionOptionButton_focus_entered")
	)


### Passes along the stored action.
func _on_ActionOptionButton_pressed() -> void:
	emit_signal("action_selected", _action)


## Passes along the stored action.
func _on_ActionOptionButton_focus_entered() -> void:
	emit_signal("action_highlighted", _action)
