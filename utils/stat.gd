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


## Gets the magic stat types aligned with light element.
static func get_light_aligned_magic() -> Array[Type]:
	return _get_aligned_magic(ElementalAlignment.get_light_elements())


## Gets the magic stat types aligned with dark element.
static func get_dark_aligned_magic() -> Array[Type]:
	return _get_aligned_magic(ElementalAlignment.get_dark_elements())


## Gets the res stat types aligned with the light element.
static func get_light_aligned_res() -> Array[Type]:
	return _get_aligned_res(ElementalAlignment.get_light_elements())


## Gets the res stat types aligned with the dark element.
static func get_dark_aligned_res() -> Array[Type]:
	return _get_aligned_res(ElementalAlignment.get_dark_elements())


## Helper function for get_light_aligned_magic and get_dark_aligned_magic. Takes
## the aligned elements and returns an array of the corresponding magic stat types.
static func _get_aligned_magic(
	aligned_elements: Array[Element.Core]
) -> Array[Type]:
	var parts: Array[Type] = []
	for element in aligned_elements:
		match element:
			Element.Core.EARTH:
				parts.append(Type.MAGIC_EARTH)
			Element.Core.FIRE:
				parts.append(Type.MAGIC_FIRE)
			Element.Core.WATER:
				parts.append(Type.MAGIC_WATER)
			Element.Core.WIND:
				parts.append(Type.MAGIC_WIND)
	return parts


## Helper function for get_light_aligned_res and get_dark_aligned_res. Takes
## the aligned elements and returns an array of the corresponding res stat types.
static func _get_aligned_res(
	aligned_elements: Array[Element.Core]
) -> Array[Type]:
	var parts: Array[Type] = []
	for element in aligned_elements:
		match element:
			Element.Core.EARTH:
				parts.append(Type.RES_EARTH)
			Element.Core.FIRE:
				parts.append(Type.RES_FIRE)
			Element.Core.WATER:
				parts.append(Type.RES_WATER)
			Element.Core.WIND:
				parts.append(Type.RES_WIND)
	return parts
