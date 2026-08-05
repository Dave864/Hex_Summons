class_name VariableTimer
extends Timer
## A continuous timer that randomizes between a range of times whenever the timer
## ends.


@export_range(0.001, 4096.0, 0.1) var lower_time: float = 1.0
@export_range(0.001, 4096.0, 0.1) var upper_time: float = 1.0


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(lower_time <= upper_time, "lower_time is higher than upper_time.")
	timeout.connect(_on_Timer_timeout)
	start(randf_range(lower_time, upper_time))


## Resets the timer to a new random time.
func reset() -> void:
	start(randf_range(lower_time, upper_time))


## Restarts the timer with a new random time.
func _on_Timer_timeout() -> void:
	reset()
