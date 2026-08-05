class_name EncounterUIWait
extends EncounterUIState
## The logic for what happens when an EncounterUI scene is in the `Wait` state.
##
## Hides the options and suboptions menus. Goes to the 'Action' state when a player
## or summon turn starts.


## Called by the state machine upon changing the active state. The `msg` parameter
## is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> void:
	encounter_ui.display_player_menu(false)
	
	# These signals are used by other states and will be disconnected to avoid
	# unintended behavior.
	SignalBus.player_turn_started.connect(_on_SignalBus_player_turn_started)


## Called by the state machine before changing the active state.
## Use this function to clean up the state.
func exit() -> void:
	SignalBus.player_turn_started.connect(_on_SignalBus_player_turn_started)


## Connects the SignalBus summon_turn_started signal.
func _ready_connect_signals() -> void:
	SignalBus.summon_turn_started.connect(_on_SignalBus_summon_turn_started)


## Set the specified player as the character of focus in EncounterUI and moves
## to the `ACTION` state.
func _on_SignalBus_player_turn_started(character: PlayerCharacter) -> void:
	if not _state_is_active():
		return
	encounter_ui.set_focused_character(character)
	state_machine.transition_to(ACTION)


## Set the active summon as the character of focus in EncounterUI and moves to
## the `ACTION` state.
func _on_SignalBus_summon_turn_started() -> void:
	encounter_ui.set_summon_as_focus()
	state_machine.transition_to(ACTION)
