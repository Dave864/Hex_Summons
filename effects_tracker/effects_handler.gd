@abstract
class_name EffectsHandler
extends Node
## Base class for handler that tracks the effects that are currently active on
## a character.


## The stats for the character. Used for determining how well an effect is
## resisted.
var _c_stats: StatModifiers = null


## Sets the reference to the character stats.
func set_character_stats(c_stats: StatModifiers) -> void:
	_c_stats = c_stats


## Updates the duration for all effects.
@abstract func progress_duration(turn_step: int = 1) -> void


## Processes the effects currently active on the character.
@abstract func process_effects() -> void


## Adds relevant effects to this handler.
@abstract func apply_effects(effects: Array[ActionEffect]) -> void


## Checks if an action effect targets the character.
func _effect_targets_character(effect: ActionEffect) -> bool:
	match effect.target:
		ActionEffect.Target.SELF:
			return effect.caster_id == _c_stats.character_id
		ActionEffect.Target.ALLIES:
			if effect.caster_type == Character.Type.SUMMON:
				return _c_stats.character_type == Character.Type.PLAYER
			if _c_stats.character_type == Character.Type.SUMMON:
				return effect.caster_type == Character.Type.PLAYER
			return effect.caster_type == _c_stats.character_type
		ActionEffect.Target.OPPONENTS:
			if effect.caster_type == Character.Type.SUMMON:
				return _c_stats.character_type == Character.Type.ENEMY
			if _c_stats.character_type == Character.Type.SUMMON:
				return effect.caster_type == Character.Type.ENEMY
			return effect.caster_type != _c_stats.character_type
		_:
			return false
