class_name Stat
extends Resource
"""
Defines the stats used by all characters: Health, Attack, Defense, Agility, Movement.
"""


# The core stats used by characters and actions.
enum Type {
	CUR_HEALTH,
	MAX_HEALTH,
	ATTACK,
	DEFENSE,
	AGILITY,
	MOVEMENT,
	MAGIC_EARTH,
	MAGIC_FIRE,
	MAGIC_WATER,
	MAGIC_WIND,
	MAGIC_LIGHT,
	MAGIC_DARK,
	RES_EARTH,
	RES_FIRE,
	RES_WATER,
	RES_WIND,
	RES_LIGHT,
	RES_DARK,
}

export(Type) var type = Type.CUR_HEALTH
