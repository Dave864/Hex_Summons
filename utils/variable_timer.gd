class_name VariableTimer
extends Timer
"""
A continuous timer that randomizes between a range of times whenever the timer
ends.
"""


export(float, 0.001, 4096.0) var lower_time = 1.0
export(float, 0.001, 4096.0) var upper_time = 1.0


# Called when the node enters the scene tree for the first time.
func _ready():
	assert(lower_time <= upper_time, "lower_time is higher than upper_time.")
	self.connect("timeout", self, "_on_Timer_timeout")
	start(rand_range(lower_time, upper_time))


# Restarts the timer with a new random time.
func _on_Timer_timeout() -> void:
	start(rand_range(lower_time, upper_time))
