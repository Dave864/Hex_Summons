class_name SummonStatModifiers
extends StatModifiers
## Tracks the stat modifications of an active summon.
##
## Uses the stats of a PlayerCharacter in conjunction with a set of multipliers
## from the active summon to determine the stats. Any modifier updates are
## applied to the player character stats.


## The stats of the character that conjured the summon.
var summoner_stats: CharacterStatModifiers = null
## The stat modifiers of the summon.
var summon_data: SummonData = null


## Returns the movement stat. Can specify if the base value should be returned
## or the value with current modifiers.
func get_movement_range(_modified: bool = true) -> int:
	if summon_data == null:
		printerr("No value for summon_data has been set.")
		return 0
	return summon_data.movement


## Set current health to the maximum value. Always uses the modified max health
## as the maximum value.
func max_cur_health() -> void:
	if summon_data == null:
		printerr("No value for summon_data has been set.")
		return
	summoner_stats.max_cur_health()


## Returns the values for all stats. Can specify if the base values should be
## returned or the values with current modifiers.
func get_all(modified: bool = true) -> Dictionary[String, Variant]:
	var all_stats: Dictionary[String, Variant] = {
		Stat.MAX_HEALTH: get_stat(Stat.Type.MAX_HEALTH, modified),
		Stat.CUR_HEALTH: get_stat(Stat.Type.CUR_HEALTH, modified),
		Stat.AGILITY: get_stat(Stat.Type.AGILITY, modified),
		Stat.MOVEMENT: get_stat(Stat.Type.MOVEMENT, modified),
	}
	all_stats.merge(get_offensive(modified))
	all_stats.merge(get_defensive(modified))
	return all_stats


## Returns the values of all offensive related stats. Can specify if the base
## values should be returned or the values with current modifiers.
func get_offensive(modified: bool = true) -> Dictionary[String, Variant]:
	return {
		Stat.ATTACK: get_stat(Stat.Type.ATTACK, modified),
		Stat.MAGIC: {
			Element.Type.EARTH: get_stat(Stat.Type.MAGIC_EARTH, modified),
			Element.Type.FIRE: get_stat(Stat.Type.MAGIC_FIRE, modified),
			Element.Type.WATER: get_stat(Stat.Type.MAGIC_WATER, modified),
			Element.Type.WIND: get_stat(Stat.Type.MAGIC_WIND, modified),
			Element.Type.LIGHT: get_stat(Stat.Type.MAGIC_LIGHT, modified),
			Element.Type.DARK: get_stat(Stat.Type.MAGIC_DARK, modified),
		}
	}


## Returns the values of all defensive related stats. Can specify if the base
## values should be returned or the values with current modifiers.
func get_defensive(modified: bool = true) -> Dictionary[String, Variant]:
	return {
		Stat.DEFENSE: get_stat(Stat.Type.DEFENSE, modified),
		Stat.RESISTANCE: {
			Element.Type.EARTH: get_stat(Stat.Type.RES_EARTH, modified),
			Element.Type.FIRE: get_stat(Stat.Type.RES_FIRE, modified),
			Element.Type.WATER: get_stat(Stat.Type.RES_WATER, modified),
			Element.Type.WIND: get_stat(Stat.Type.RES_WIND, modified),
			Element.Type.LIGHT: get_stat(Stat.Type.RES_LIGHT, modified),
			Element.Type.DARK: get_stat(Stat.Type.RES_DARK, modified),
		}
	}


## Returns the value for a specific stat. Can specify if the base value should
## be returned or the value with current modifiers.
func get_stat(stat: Stat.Type, modified: bool = true) -> int:
	if summoner_stats == null or summon_data == null:
		printerr("Missing either summoner_stats or summon_data.")
		return 0
	var base_value: int = summoner_stats.get_stat(stat, modified)
	var multiplier: float = summon_data.multiplier_for_stat(stat)
	return roundi(base_value * multiplier)


## Updates the modifier for the specified stat so that it results in the new
## value when added to the base value of the stat.
func update_modifier(stat: Stat.Type, value: int) -> void:
	if summoner_stats == null:
		printerr("Missing summoner_stats.")
		return
	summoner_stats.update_modifier(stat, value)


## Sets the values of all the modifiers to zero.
func clear_modifiers() -> void:
	if summoner_stats == null:
		printerr("Missing summoner_stats.")
		return
	summoner_stats.clear_modifiers()


## Check that all required parameters are set.
func _check_for_required_parameters() -> void:
	pass
