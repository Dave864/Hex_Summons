class_name EffectsTracker
extends Node
## Manages all of the effect handlers for a character.
##
## Receives Action hit box collision data and passes it along to the relevant
## handlers.


var _c_stats: CharacterStats = null: set = set_character_stats


## Sets the reference to the provided CharacterStats.
func set_character_stats(c_stats: CharacterStats) -> void:
	_c_stats = c_stats
	for e_handler in get_children():
		e_handler.set_character_stats(_c_stats)


## Progress the duration of all effects in all handlers by the specified turn step.
func progress_duration(turn_step: int = 1) -> void:
	for e_handler in get_children():
		e_handler.progress_duration(turn_step)


## Process the effects on all handlers.
func process_effects() -> void:
	for e_handler in get_children():
		e_handler.process_effects()


## Connects the effects of an action to this manager.
func _on_HitBox_area_entered(hit_box: ActionHitBox) -> void:
	var effects: Array = hit_box.get_effects()
	for e_handler in get_children():
		if e_handler is EffectsHandler:
			e_handler.apply_effects(
					effects,
					hit_box.caster_id,
					_c_stats.character_id
			)
