class_name AllStats
extends Object
## Stores stat values for a character.
##
## Stores values for level, max health, current_health, agility, movement,
## attack, defense, magic, and resistance. Contains OffensiveStats and
## DefensiveStats objects to store offensive (attack and magic) and defensive
## (defense and resistance) stats respectively.


## The level value.
var _level: int = 0
## The current health value.
var _cur_health: int = 0
## The maximum health value.
var _max_health: int = 0
## The agility value.
var _agility: int = 0
## The movement value.
var _movement: int = 0
## Stores the values for attack and magic.
var _offensive_stats: OffensiveStats = null
## Stores the values for defense and resistance.
var _defensive_stats: DefensiveStats = null


func _init(
	level_value: int,
	cur_health_value: int,
	max_health_value: int,
	agility_value: int,
	movement_value: int,
	new_offensive_stats: OffensiveStats,
	new_defensive_stats: DefensiveStats
) -> void:
	_level = level_value
	_cur_health = cur_health_value
	_max_health = max_health_value
	_agility = agility_value
	_movement = movement_value
	_offensive_stats = new_offensive_stats
	_defensive_stats = new_defensive_stats


## Gets the value for the given stat.
func get_stat(stat: Stat.Type) -> int:
	match stat:
		Stat.Type.CUR_HEALTH:
			return get_cur_health()
		Stat.Type.MAX_HEALTH:
			return get_max_health()
		Stat.Type.ATTACK:
			return get_attack()
		Stat.Type.DEFENSE:
			return get_defense()
		Stat.Type.AGILITY:
			return get_agility()
		Stat.Type.MOVEMENT:
			return get_movement()
		Stat.Type.MAGIC_EARTH:
			return get_magic(Element.Type.EARTH)
		Stat.Type.MAGIC_FIRE:
			return get_magic(Element.Type.FIRE)
		Stat.Type.MAGIC_WATER:
			return get_magic(Element.Type.WATER)
		Stat.Type.MAGIC_WIND:
			return get_magic(Element.Type.WIND)
		Stat.Type.RES_EARTH:
			return get_resistance(Element.Type.EARTH)
		Stat.Type.RES_FIRE:
			return get_resistance(Element.Type.FIRE)
		Stat.Type.RES_WATER:
			return get_resistance(Element.Type.WATER)
		Stat.Type.RES_WIND:
			return get_resistance(Element.Type.WIND)
		_:
			return 0


## Gets the level value.
func get_level() -> int:
	return _level


## Gets the current health value.
func get_cur_health() -> int:
	return _cur_health


## Gets the max health value.
func get_max_health() -> int:
	return _max_health


## Gets the agility value.
func get_agility() -> int:
	return _agility


## Gets the movement value.
func get_movement() -> int:
	return _movement


## Gets the attack stat value.
func get_attack() -> int:
	return _offensive_stats.get_attack()


## Gets the value for the magic stat of a given element.
func get_magic(element: Element.Type) -> int:
	return _offensive_stats.get_magic(element)


## Gets the defense stat value.
func get_defense() -> int:
	return _defensive_stats.get_defense()


## Gets the value for the resistance stat of a given element.
func get_resistance(element: Element.Type) -> int:
	return _defensive_stats.get_res(element)
