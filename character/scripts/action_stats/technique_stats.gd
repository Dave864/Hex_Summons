class_name TechniqueStats
extends Resource
## Describes a technique. Techniques are actions with a cooldown.


## The stats for this technique.
@export var action_stats: ActionStats = null
## The cooldown turn count.
@export_range(0, 10) var cooldown: int = 0

## The current countdown value.
var _countdown: int = 0: get = get_countdown


## Called when the node enters the scene tree for the first time.
func _ready():
	assert(
			action_stats is ActionStats,
			"Parameter action_stats is not of type ActionStats."
	)


## Gets the current value of the countdown.
func get_countdown() -> int:
	return _countdown


## Checks if the countdown is active.
func is_active() -> bool:
	return _countdown > 0


## Starts the cooldown countdown.
func start_countdown() -> void:
	_countdown = cooldown


## Starts the cooldown countdown. Used when the countdown is started during the
## character's turn. Need to add one extra count so that cooldown duration
## matches turn_count.
func start_countdown_on_turn() -> void:
	_countdown = cooldown + 1


## Decrement the countdown when a character turn ends.
func _on_Character_turn_ended() -> void:
	_countdown = 0 if _countdown == 0 else _countdown - 1
