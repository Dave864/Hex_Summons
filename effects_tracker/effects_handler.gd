@abstract
class_name EffectsHandler
extends Node
## Base class for handler that tracks the effects that are currently active on
## a character.


var _c_stats: CharacterStatModifiers = null: set = set_character_stats


## Sets the reference to the character stats.
func set_character_stats(c_stats: CharacterStatModifiers) -> void:
	_c_stats = c_stats


## Updates the duration for all effects.
@abstract func progress_duration(_turn_step: int = 1) -> void


## Processes the effects currently active on the character.
@abstract func process_effects() -> void


## Adds relevant effects to this handler.
@abstract func apply_effects(
	_effects: Array[Effect],
	_caster_id: int,
	_target_id: int
) -> void
