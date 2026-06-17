@abstract
class_name EncounterSpawnAlert
extends EncounterSpawnState
## Base class for the logic of the `Alert ` state.
##
## The spawner generally stops and waits for the tracked target to either get
## too close or leave detection range. The specific behavior each type of
## EncounterSpawn has must be defined in derived classes.


## Virtual function. Called by the state machine upon changing the active state.
## The `msg` parameter is a dictionary with arbitrary data the state can use to
## initialize itself.
func enter(_msg: Dictionary[Variant, Variant] = {}) -> void:
	pass


## Virtual function. Receives events from the `_unhandled_input()` callback.
func handle_input(_event: InputEvent) -> void:
	pass


## Virtual function. Corresponds to the `_process()` callback.
func update(_delta: float) -> void:
	pass


## Virtual function. Corresponds to the `_physics_process()` callback.
func physics_update(_delta: float) -> void:
	pass


## Virtual function. Called by the state machine before changing the active
## state. Use this function to clean up the state.
func exit() -> void:
	pass
