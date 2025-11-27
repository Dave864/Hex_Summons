class_name Stat
extends Resource
## Specifies a character stat.
##
## Specifies one of the possible character stats: Health, Attack, Defense,
## Agility, Movement, Magic, and Resistance. Maigic and Resistance is further
## broken down into all of the elements, core (earth, fire, water, wind) and
## alignment (light, dark).


## The core stats used by characters and actions.
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

@export var type: Type = Type.CUR_HEALTH
