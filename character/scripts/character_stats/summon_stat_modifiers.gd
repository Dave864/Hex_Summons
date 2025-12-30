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


## Updates the current health by the given delta.
func set_cur_health(delta: int) -> int:
	return summoner_stats.set_cur_health(delta)


## Set current health to the maximum value. Always uses the modified max health
## as the maximum value.
func max_cur_health() -> void:
	if summon_data == null:
		printerr("No value for summon_data has been set.")
		return
	summoner_stats.max_cur_health()


## Returns the values for all stats. Can specify if the base values should be
## returned or the values with current modifiers.
func get_all(modified: bool = true) -> AllStats:
	return AllStats.new(
		summoner_stats.get_level(),
		get_stat(Stat.Type.CUR_HEALTH, modified),
		get_stat(Stat.Type.MAX_HEALTH, modified),
		get_stat(Stat.Type.AGILITY, modified),
		get_stat(Stat.Type.MOVEMENT, modified),
		get_offensive(modified),
		get_defensive(modified)
	)


## Returns the values of all offensive related stats. Can specify if the base
## values should be returned or the values with current modifiers.
func get_offensive(modified: bool = true) -> OffensiveStats:
	return OffensiveStats.new(
		get_stat(Stat.Type.ATTACK, modified),
		get_stat(Stat.Type.MAGIC_EARTH, modified),
		get_stat(Stat.Type.MAGIC_FIRE, modified),
		get_stat(Stat.Type.MAGIC_WATER, modified),
		get_stat(Stat.Type.MAGIC_WIND, modified)
	)


## Returns the values of all defensive related stats. Can specify if the base
## values should be returned or the values with current modifiers.
func get_defensive(modified: bool = true) -> DefensiveStats:
	return DefensiveStats.new(
		get_stat(Stat.Type.DEFENSE, modified),
		get_stat(Stat.Type.RES_EARTH, modified),
		get_stat(Stat.Type.RES_FIRE, modified),
		get_stat(Stat.Type.RES_WATER, modified),
		get_stat(Stat.Type.RES_WIND, modified),
	)


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
