class_name SelectionTrackerWait
extends SelectionTrackerState
## The logic for what happens when the SelectionTracker is in the 'Wait' state.
##
## The selector hides its shape and disables the snap position functionality
## until the encounter is ready to recieve new player selections.


## Connect to the player_turn_started signal from the SignalBus.
func enter(_msg: Dictionary[Variant, Variant] = {}) -> void:
	selector.hide()
	s_tracker.show_ghost_sprite(false)
	s_tracker.focused_character = null


## Virtual function. To be called in the _ready function to connect signals to 
## the state. The signals connected here should not be required by other states.
func _ready_connect_signals() -> void:
	SignalBus.player_turn_started.connect(_on_SignalBus_player_turn_started)
	SignalBus.summon_turn_started.connect(_on_SignalBus_summon_turn_started)


## Set the active character to be the player whose turn has started and move
## to the `SelectMove` state.
func _on_SignalBus_player_turn_started(player: PlayerCharacter) -> void:
	s_tracker.focused_character = player
	s_tracker.move_target_index = s_tracker.player_index
	state_machine.transition_to(MOVE)


## Move to the `SelectMove` state. The active character should have already
## been set by the Encounter FSM.
func _on_SignalBus_summon_turn_started() -> void:
	s_tracker.move_target_index = s_tracker.player_index
	state_machine.transition_to(MOVE)
