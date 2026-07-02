@abstract
class_name EncounterSpawnIdle
extends EncounterSpawnState
## Base class for the logic of the `Idle` state.
##
## The spawner can either roam around a point or travel to a point. Each type of
## EncounterSpawn has different criteria for entering the `Alert` state, which
## must be defined in derived classes.


## The possible patterns the EncounterSpawn could follow
enum BehaviorPattern {
	ROAM,
	TRAVEL,
	UNDECIDED,
}

## The pattern followed by EncounterSpawn.
var _current_pattern := BehaviorPattern.UNDECIDED


## Virtual function. Called by the state machine upon changing the active state.
## The `msg` parameter is a dictionary with arbitrary data the state can use to
## initialize itself.
func enter(_msg: Dictionary[Variant, Variant] = {}) -> void:
	_current_pattern = (
			BehaviorPattern.ROAM if enc_spawn.roam_area != null
			else BehaviorPattern.TRAVEL
	)


## Virtual function. Corresponds to the `_process()` callback.
func update(_delta: float) -> void:
	pass


## Virtual function. Corresponds to the `_physics_process()` callback.
func physics_update(_delta: float) -> void:
	match _current_pattern:
		BehaviorPattern.ROAM:
			pass
		BehaviorPattern.TRAVEL:
			pass
		_:
			return


## Virtual function. Called by the state machine before changing the active
## state. Use this function to clean up the state.
func exit() -> void:
	pass


## Virtual function. To be called in the _ready function to connect signals to 
## the state. The signals connected here should not be required by other states.
func _ready_connect_signals() -> void:
	enc_spawn.alert_range.connect(
			"body_entered",
			Callable(self, "_on_AlertRange_body_entered")
	)


## Triggers a transition to the `Alert` state when a relevant body enters the
## alert area.
func _on_AlertRange_body_entered(body: Node3D) -> void:
	if not _state_is_active():
		return
	if body is OverworldAvatar:
		state_machine.transition_to(ALERT, {"AlertFocus": body})
	if body is EncounterSpawn:
		_process_encounter_spawn(body)


## The behavior for determining what should happen when another EncounterSpawn
## is detected.
@abstract func _process_encounter_spawn(spawn: EncounterSpawn) -> void
