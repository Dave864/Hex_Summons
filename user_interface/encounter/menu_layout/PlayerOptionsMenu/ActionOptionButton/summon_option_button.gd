class_name SummonOptionButton
extends ActionOptionButton
## A button that represents a summon option.
##
## Tracks the summon that this button is for. Passes along its spawn action data
## when this button is pressed.


## Creates a button with the specified summon, getting its details from the
## summon manager.
func _init(summon_name: String, spawn_action: Action) -> void:
	_action = spawn_action
	name = summon_name
	text = name
	alignment = HORIZONTAL_ALIGNMENT_CENTER
	flat = true
	connect("pressed", Callable(self, "_on_ActionOptionButton_pressed"))
	connect(
			"focus_entered",
			Callable(self, "_on_ActionOptionButton_focus_entered")
	)


### Inidicates that a spawn action has been selected.
func _on_ActionOptionButton_pressed() -> void:
	SignalBus.emit_spawn_action_selected(name, _action)
