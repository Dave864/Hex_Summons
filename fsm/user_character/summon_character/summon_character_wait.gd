class_name SummonCharacterWait
extends UserCharacterWait
## The logic for what happens when a summon is in the `Wait` state.
##
## The summon waits and is inactive until it is reenabled.


## Virtual function. To be called in the _ready function to connect signals to 
## the state. The signals connected here should not be required by other states.
func _ready_connect_signals() -> void:
	SignalBus.connect(
			"summon_turn_started",
			Callable(self, "_on_SignalBus_summon_turn_started")
	)


## Hit when the summon character is selected to take a turn. Transitions to
## `Standby` when the summon is signaled to start.
func _on_SignalBus_summon_turn_started() -> void:
	state_machine.transition_to(STANDBY)
