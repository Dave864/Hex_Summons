class_name Stat
extends Object
## A collection of enums and constants that are used for character statistics.
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

## The different operations that can be performed on character stats.
enum Operation {
	INCREASE,
	DECREASE,
	SET,
}

# Words referring to different character stats.
const LEVEL: String = "Level"
const MOVEMENT: String = "Movement"
const MAX_HEALTH: String = "Max Health"
const CUR_HEALTH: String = "Current Health"
const ATTACK: String = "Attack"
const DEFENSE: String = "Defense"
const AGILITY: String = "Agility"
const MAGIC: String = "Magic"
const RESISTANCE: String = "Resistance"
