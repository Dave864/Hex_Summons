class_name EncounterSpawnDespawn
extends EncounterSpawnState
## Base class for the logic of the `Despawn` state.
##
## The EncounterSpawn is made inactive and the sprite transitions to becoming
## invisible before the node itself is removed from the scene. The transition to
## invisibility could have EncounterSpawn stay still, move away from the
## the direction it was previosly traveling, or continue moving in its last
## travel direction.


## Virtual function. Called by the state machine upon changing the active state.
## The `msg` parameter is a dictionary with arbitrary data the state can use to
## initialize itself.
func enter(_msg: Dictionary[Variant, Variant] = {}) -> void:
	if enc_spawn.is_active():
		enc_spawn.emit_despawned()
	enc_spawn.sprite.transition_finished.connect(
			_on_EncounterSpawnSprite_transition_finished
	)
	enc_spawn.sprite.ready_despawn_transition()


## Virtual function. Corresponds to the `_process()` callback.
func update(delta: float) -> void:
	enc_spawn.sprite.progress_transition(delta)


## Override parent function so that despawn signal is not detected.
func _ready_connect_signals() -> void:
	return


## Queue EncounterSpawn for deletion when its sprite completes the transition.
func _on_EncounterSpawnSprite_transition_finished() -> void:
	enc_spawn.queue_free()
