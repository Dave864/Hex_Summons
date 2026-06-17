@abstract
class_name EncounterSpawnDespawn
extends EncounterSpawnState
## Base class for the logic of the `Despawn` state.
##
## The EncounterSpawn is made inactive and the sprite transitions to becoming
## invisible before the node itself is removed from the scene. The transition to
## invisibility could have EncounterSpawn stay still, move away from the
## the direction it was previosly traveling, or continue moving in its last
## travel direction. The specific behavior for each EncounterSpawn type must be
## defined in derived classes.


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
