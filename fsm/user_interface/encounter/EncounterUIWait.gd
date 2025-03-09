extends EncounterUIState
"""
The logic for what happens when an EncounterUI scene is in the `Wait` state.
Hides the options and suboptions menus. Goes to the 'Select' state when a player
turn starts.
"""


# Called by the state machine upon changing the active state. The `msg` parameter
# is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> void:
	encounter_ui.sub_options.hide()
	encounter_ui.options.hide()
	encounter_ui.active_player_stats.hide()


# Corresponds to the `_process()` callback.
func update(_delta: float) -> void:
	pass


# Called by the state machine before changing the active state.
# Use this function to clean up the state.
func exit() -> void:
	pass


func _ready_connect_signals():
	ErrorUtil.connect_signal(
		SignalBus,
		"player_turn_started",
		self,
		"_on_SignalBus_player_turn_started"
	)


# Gets the current player and moves to the 'ActionSelect' state.
func _on_SignalBus_player_turn_started(player: PlayerCharacter) -> void:
	encounter_ui.set_focused_player(player)
	state_machine.transition_to(STANDBY)
