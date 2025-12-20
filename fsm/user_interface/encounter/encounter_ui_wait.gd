class_name EncounterUIWait
extends EncounterUIState
## The logic for what happens when an EncounterUI scene is in the `Wait` state.
##
## Hides the options and suboptions menus. Goes to the 'Move' state when a player
## or summon turn starts.


## Called by the state machine upon changing the active state. The `msg` parameter
## is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> void:
	encounter_ui.sub_options.deactivate()
	encounter_ui.options.hide()
	encounter_ui.hide_active_stats()
	
	# These signals are used by other states and will be disconnected to avoid
	# unintended behavior.
	SignalBus.connect(
		"player_turn_started",
		Callable(self, "_on_SignalBus_player_turn_started")
	)
	encounter_ui.emit_is_waiting()


## Called by the state machine before changing the active state.
## Use this function to clean up the state.
func exit() -> void:
	SignalBus.disconnect(
		"player_turn_started",
		Callable(self, "_on_SignalBus_player_turn_started")
	)


## Connects the SignalBus summon_turn_started signal.
func _ready_connect_signals() -> void:
	SignalBus.connect(
			"summon_turn_started",
			Callable(self, "_on_SignalBus_summon_turn_started")
	)


## Set the specified player as the character of focus in EncounterUI and moves
## to the `MOVE` state.
func _on_SignalBus_player_turn_started(character: PlayerCharacter) -> void:
	if not _state_is_active():
		return
	encounter_ui.set_focused_player(character)
	state_machine.transition_to(MOVE)


## Set the active summon as the character of focus in EncounterUI and moves to
## the `MOVE` state.
func _on_SignalBus_summon_turn_started() -> void:
	# TODO: Call appropriate functions to set summon as focused character when
	# they have been implemented.
	print("Summon turn start detected")
	state_machine.transition_to(WAIT)
	#state_machine.transition_to(MOVE)
