class_name TutorialSummonTurn
extends TutorialState
## The logic for what happens when an Tutorial scene is in the `SummonTurn`
## state.
##
## Handles the tutorial logic needed to allow the summon character to properly
## run during their turn. Goes to the `PlayerTurn` state if the next character
## in initiative is also a player character. Goes to the `EnemyTurn` state if an
## enemy character is next in intiative. Goes to the `End` state if all player
## characters are defeated. When all enemy characters are defeated, it will
## prompt the map selector to highlight the transition zone. When all tutorial
## steps are finished, defeating all enemy characters will trigger a transition
## to the `End` state.


## Flag that tracks if the summon is waiting. Used when changing to another
## character's turn.
var _summon_waiting: bool = false


## Called by the state machine upon changing the active state. The `msg` parameter
## is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> void:
	_summon_waiting = false
	tutorial.selection_tracker.focused_character = tutorial.summon
	await tutorial.camera.move_focus_decay(tutorial.summon.position)
	tutorial.camera.enable_edge_detection()
	SignalBus.emit_summon_turn_started()


## Connect signals that will persist throughout the life of this state.
func _ready_connect_signals() -> void:
	tutorial.summon.is_waiting.connect(_on_SummonCharacter_is_waiting)
	tutorial.summon.turn_ended.connect(_on_Summon_turn_ended)


## Returns if the tutorial has reached its end. Triggers a state change if
## it has.
func _reached_end() -> bool:
	if tutorial.players_defeated() or tutorial.enemies_defeated():
		state_machine.transition_to(END)
		return true
	return false


## Marks the player as waiting.
func _on_SummonCharacter_is_waiting() -> void:
	_summon_waiting = true


## Clear the tile movement highlights, update the initiative tracker and
## transition to either the PlayerTurn state, or the EnemyTurn state depending
## on the next character.
func _on_Summon_turn_ended() -> void:
	tutorial.selection_tracker.clear_highlights()
	tutorial.selection_tracker.clear_indicators()
	if not _summon_waiting:
		await tutorial.summon.is_waiting
	if _reached_end():
		return
	var next_character: Character = tutorial.get_next_character()
	tutorial.progress_initiative()
	if next_character is PlayerCharacter:
		state_machine.transition_to(PLAYER_TURN)
	elif next_character is EnemyCharacter:
		state_machine.transition_to(ENEMY_TURN)
