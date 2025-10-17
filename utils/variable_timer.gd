class_name VariableTimer
extends Timer
"""
A continuous timer that randomizes between a range of times whenever the timer
ends.
"""


@export var lower_time = 1.0 # (float, 0.001, 4096.0)
@export var upper_time = 1.0 # (float, 0.001, 4096.0)


# Resets the timer to a new random time.
func reset() -> void:
	start(randf_range(lower_time, upper_time))


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(lower_time <= upper_time, "lower_time is higher than upper_time.")
	self.connect("timeout", Callable(self, "_on_Timer_timeout"))
	start(randf_range(lower_time, upper_time))


# Restarts the timer with a new random time.
func _on_Timer_timeout() -> void:
	reset()
