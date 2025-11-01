class_name Cooldown
extends Node
## A timer that updates whenever a character's turn ends.


## The number of turns the cooldown is active for.
@export var turn_count = 0 # (int, 0, 10)

## Tracks the countdown value when the cooldown is active. A value of 0 indicates
## the countdown has completed.
var _countdown: int = 0: get = get_countdown


## Gets the current value of the countdown.
func get_countdown() -> int:
	return _countdown


## Checks if the countdown is active.
func is_active() -> bool:
	return _countdown > 0


## Starts the cooldown countdown.
func start_countdown() -> void:
	_countdown = turn_count


## Starts the cooldown countdown. Used when the countdown is started during the
## character's turn. Need to add one extra count so that cooldown duration
## matches turn_count.
func start_countdown_on_turn() -> void:
	_countdown = turn_count + 1


## Creates a new Cooldown node with a specific turn count value. The Cooldown
## is inactive upon creation.
func _init(turn_count_value: int = 0) -> void:
	name = "Cooldown"
	turn_count = turn_count_value
	_countdown = 0


## Decrement the countdown when a character turn ends.
func _on_Character_turn_ended() -> void:
	_countdown = 0 if _countdown == 0 else _countdown - 1
