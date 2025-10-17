class_name AdjacentCondition
extends ActionCondition
"""
ActionCondition that checks if there are a certain number of opposing characters
adjacent.
"""


enum Condition {
	EQUALS,
	AT_LEAST,
	UP_TO
}

@export var adjacent_check = 1 # (int, 0, 10)
@export var check_type: Condition = Condition.EQUALS


# Virtual function. Checks if the condition has been met given the current
# state of the characters and map.
func is_met(
	_character: Character,
	targets: Array,
	distance_map: DistanceMap
) -> bool:
	var adj_ct: int = _determine_adjacent_count(targets, distance_map)
	return (
			adj_ct <= adjacent_check if check_type == Condition.UP_TO
			else adj_ct >= adjacent_check if check_type == Condition.AT_LEAST
			else adj_ct == adjacent_check
	)


# Calculate the number of adjacent characters from a given set.
func _determine_adjacent_count(
	characters_to_check: Array,
	distance_map: DistanceMap
) -> int:
	var adjacent_count: int = 0
	var char_coord: int
	for character in characters_to_check:
		char_coord = character.map_coordinate.get_tile_index()
		if distance_map.travel_dist_at(char_coord) == 1.0:
			adjacent_count += 1
	return adjacent_count
