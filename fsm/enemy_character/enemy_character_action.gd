class_name EnemyCharacterAction
extends EnemyCharacterState
## The logic for what happens when an Enemy Character is in the `Action` state.
##
## The Enemy Character executes a given action and then proceeds to the next command
## in the given chain. Goes to the 'Wait' state if the action is the last command.


## The path to the cooldown node of an action. Should always be a child of
## ActionBehavior.
const COOLDOWN_PATH: String = "ActionBehavior/Cooldown"

## The list of commands the enemy will execute.
var _command_chain: Array[Array] = []


## Called by the state machine upon changing the active state. The `msg` parameter
## is a dictionary with arbitrary data the state can use to initialize itself.
func enter(msg := {}) -> void:
	_command_chain = msg["command_chain"]
	var action_details: Array[Variant] = _command_chain.pop_back()
	var action: Action = action_details[1]
	var targets: Array[Character] = action_details[3]
	_change_target_state(targets, true)
	await action.execute_action()
	_change_target_state(targets, false)
	_activate_cooldown(action)
	_move_to_next_state()


## Corresponds to the `_process()` callback.
func update(_delta: float) -> void:
	pass


## Called by the state machine before changing the active state.
## Resets the interpolation weight an next_point_index.
func exit() -> void:
	pass


## Checks the command chain to determine what state to go to next.
func _move_to_next_state() -> void:
	if _command_chain.size() > 0:
		if _command_chain.back()[0] == MOVE:
			print("Go to move")
			state_machine.transition_to(MOVE, {"command_chain": _command_chain})
		elif _command_chain.back()[0] == ACTION:
			print("Go to action")
			state_machine.transition_to(ACTION, {"command_chain": _command_chain})
	else:
		ec.emit_turn_ended()
		state_machine.transition_to(WAIT)


## Changes the state of the targets.
func _change_target_state(targets: Array[Character], active: bool) -> void:
	for t: Character in targets:
		if active:
			t.activate_hit_box()
		else:
			t.deactivate_hit_box()


## Activates the cooldown of an action if present.
func _activate_cooldown(action: Action) -> void:
	var cooldown: Cooldown = action.get_node_or_null(COOLDOWN_PATH)
	if cooldown != null:
		cooldown.start_countdown_on_turn()
