class_name Cooldown
extends Node
"""
Represents the number of turns that need to pass before an action can be used
again.
"""


export(int, 0, 10) var turn_count = 0

var _countdown: int = 0 setget , get_countdown


# Gets the current value of the countdown.
func get_countdown() -> int:
	return _countdown


# Checks if the countdown is active.
func is_active() -> bool:
	return _countdown > 0


# Starts the cooldown countdown.
func start_countdown() -> void:
	_countdown = turn_count


# Decrement the countdown when a character turn ends.
func _on_Character_turn_ended() -> void:
	_countdown = 0 if _countdown == 0 else _countdown - 1
