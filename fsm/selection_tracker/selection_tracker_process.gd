class_name SelectionTrackerProcess
extends SelectionTrackerState
## The logic for what happens when the SelectionTracker is in the 'Process' state.
##
## The Selector is set to inactive and hidden. Any movement paths and selected
## action are processed. Movement is processed first, followed by any action.
## The SelectionTracker goes into the 'Wait' state after completing both, if any.


## Called by the state machine upon changing the active state. The `msg` parameter
## is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg: Dictionary[Variant, Variant] = {}) -> void:
	s_tracker.focused_character.connect(
			"turn_ended",
			Callable(self, "_on_Character_turn_ended")
	)
	SignalBus.connect(
			"character_movement_finished",
			Callable(self, "_on_SignalBus_character_movement_finished")
	)
	s_tracker.clear_highlights()
	s_tracker.clear_indicators()
	s_tracker.show_ghost_sprite(false)
	s_tracker.move_path_display.hide()
	selector.hide()
	selector.tile_hovered.set_selector_type(HexHighlighter.Option.NONE)
	var movement_path: PackedVector3Array = s_tracker.get_movement_path()
	if movement_path.size() <= 1:
		_on_SignalBus_character_movement_finished()
	else:
		SignalBus.emit_position_camera_focus(
				s_tracker.focused_character.position,
				TrackingPoint.MovementType.DECAYING
		)
		await SignalBus.camera_target_reached
		SignalBus.emit_move_path_created(movement_path)


## Called by the state machine before changing the active state. Use this 
## function to clean up the state.
func exit() -> void:
	s_tracker.focused_character.disconnect(
			"turn_ended",
			Callable(self, "_on_Character_turn_ended")
	)
	SignalBus.disconnect(
			"character_movement_finished",
			Callable(self, "_on_SignalBus_character_movement_finished")
	)


## Executes the current focused action, otherwise moves to the "WAIT" state.
func _on_SignalBus_character_movement_finished() -> void:
	var action: Action = s_tracker.get_focus_action()
	if action == null:
		s_tracker.focused_character.emit_turn_ended()
		return
	if s_tracker.get_active_summon() != "":
		s_tracker.emit_spawn_action_confirmed()
	SignalBus.emit_character_action_executed(
			s_tracker.focused_character,
			action,
			s_tracker.get_tracked_targets()
	)
	s_tracker.set_active_summon("")
	s_tracker.set_focus_action(null)


## Transition to the "WAIT" state when the current character's turn has ended.
func _on_Character_turn_ended() -> void:
	if not _state_is_active():
		return
	state_machine.transition_to(WAIT)
