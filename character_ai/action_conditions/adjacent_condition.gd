class_name AdjacentCondition
extends ActionCondition
"""
ActionCondition that checks if there are a certain number of opposing characters
adjacent.
"""


enum Condition {
	EQUALS,
	MORE,
	LESS
}

export(int, 0, 10) var adjacent_check = 1
export(Condition) var check_type = Condition.EQUALS


# Virtual function. Checks if the condition has been met given the current
# state of the characters and map.
func is_met(
	character: Character,
	targets: Array,
	distance_map: Dictionary
) -> bool:
	var adjacent_count: int = _determine_adjacent_count(targets, distance_map)
	return (
			adjacent_check < adjacent_check if check_type == Condition.LESS
			else adjacent_count > adjacent_check if check_type == Condition.MORE
			else adjacent_count == adjacent_check
	)


# Calculate the number of adjacent characters from a given set.
func _determine_adjacent_count(
	characters_to_check: Array,
	distance_map: Dictionary
) -> int:
	var adjacent_count: int = 0
	var char_coord: int
	for character in characters_to_check:
		char_coord = character.map_coordinate.get_index()
		if distance_map[char_coord]["travel"] == 1.0:
			adjacent_count += 1
	return adjacent_count
