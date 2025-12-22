class_name ArraySorters
extends Object
## Collection of sorting methods.


## Sorts characters by their agility. Used when determining initiative order.
static func sort_character_initiative(a: Character, b: Character) -> bool:
	return a.stats.get_stat(Stat.Type.AGILITY) > b.stats.get_stat(Stat.Type.AGILITY)


## Sorts characters by their distances in ascending order.
## Takes in two arrays, each of which contains two items.
## The first element is the character.
## The second element is the distance.
static func sort_distance_to_character_asc(
	c1: Array[Variant],
	c2: Array[Variant]
) -> bool:
	return c1[1] < c2[1]


## Sorts characters by their distances in descending order.
## Takes in two arrays, each of which contains two items.
## The first element is the character.
## The second element is the distance.
static func sort_distance_to_character_desc(
	c1: Array[Variant],
	c2: Array[Variant]
) -> bool:
	return not sort_distance_to_character_asc(c1, c2)
