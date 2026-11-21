class_name SummonOptionButton
extends ActionOptionButton
## A button that represents a summon option.
##
## Tracks the summon that this button is for. Passes along its spawn action data
## when this button is pressed.


## Indicates that the spawn action this button represents has been highlighted.
## Passes along the action and its wisp cost.
signal summon_highlighted(action, cost)

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
	pressed.connect(_on_ActionOptionButton_pressed)
	focus_entered.connect(_on_ActionOptionButton_focus_entered)


## Indicates that a spawn action has been selected. Does nothing is a summon
## is already active.
func _on_ActionOptionButton_pressed() -> void:
	if _sumon_manager_ref == null:
		printerr("No summon handler specified for SummonButton.")
		return
	if _sumon_manager_ref.is_active():
		return
	_sumon_manager_ref.set_cost_for_spawn_action(name)
	SignalBus.emit_spawn_action_selected(name, _action)


## Passes along the stored action.
func _on_ActionOptionButton_focus_entered() -> void:
	summon_highlighted.emit(
			_action,
			_sumon_manager_ref.available_summons[name].cost_summary()
	)
