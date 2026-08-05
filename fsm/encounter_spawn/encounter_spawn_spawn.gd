class_name EncounterSpawnSpawn
extends EncounterSpawnState
## The logic for what happens when an EncounterSpawn is in the `Spawn` state.
##
## The sprite for the EncounterSpawn is slowly made visible before going to the
## `Idle` state.


## Virtual function. Called by the state machine upon changing the active state.
## The `msg` parameter is a dictionary with arbitrary data the state can use to
## initialize itself.
func enter(_msg: Dictionary[Variant, Variant] = {}) -> void:
	enc_spawn.sprite.transition_finished.connect(
			_on_EncounterSpawnSprite_transition_finished
	)
	enc_spawn.sprite.ready_spawn_transition()


## Virtual function. Corresponds to the `_process()` callback. Progresses the
## transition of the sprite.
func update(delta: float) -> void:
	enc_spawn.sprite.progress_transition(delta)


## Virtual function. Called by the state machine before changing the active
## state. Use this function to clean up the state.
func exit() -> void:
	enc_spawn.sprite.transition_finished.disconnect(
			_on_EncounterSpawnSprite_transition_finished
	)


## Move to the `Alert` state when EncounterSpawn sprite completes the transition.
func _on_EncounterSpawnSprite_transition_finished() -> void:
	enc_spawn.set_active(true)
	state_machine.transition_to(IDLE, {})
