class_name SummonOptionButton
extends ActionOptionButton
## A button that represents a summon option.
##
## Tracks the summon that this button is for. Passes along its spawn action data
## when this button is pressed.


## The summon manager.
var _sumon_manager_ref: Summon = null


## Creates a button with the specified summon, getting its details from the
## summon manager.
func _init(
	summon_name: String,
	spawn_action: Action,
	summon_manager: Summon
) -> void:
	_action = spawn_action
	_sumon_manager_ref = summon_manager
	name = summon_name
	text = name
	alignment = HORIZONTAL_ALIGNMENT_CENTER
	flat = true
	pressed.connect(_on_ActionOptionButton_pressed)
	focus_entered.connect(_on_ActionOptionButton_focus_entered)


### Indicates that a spawn action has been selected.
func _on_ActionOptionButton_pressed() -> void:
	_sumon_manager_ref.set_cost_for_spawn_action(name)
	SignalBus.emit_spawn_action_selected(name, _action)
