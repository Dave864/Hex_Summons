class_name GroupCondition
extends ActionCondition
## ActionCondition that checks if at least a certain number of opposing characters
## are grouped together.
##
## Characters need to be within a certain distance of each other to be considered
## grouped.


enum groupStatus {
	UNDEFINED,
	NOISE,
	GROUPED
}

## The minimum number of characters that are considered a group.
@export_range(2, 10) var min_group_size: int = 2
## The maximum number of tiles characters can be away from each other to be
## considered in a group.
@export_range(1, 10) var max_distance: int = 1

## Stores an array of Characters that are part of a group as the values,
## referenced by a group number.
var _groups: Dictionary[int, Array] = {}


## Virtual function. Checks if the condition has been met given the current
## state of the characters and map.
func is_met(
	_character: Character,
	targets: Array[Character],
	_distance_map: DistanceMap
) -> bool:
	_groups.clear()
	return _determine_groups(targets)


## Determines the map index coordinates that best represents the center point of
## groups. Calculates the centroid to use as the center. Accepts the number of
## tiles in a row of a hex map as a parameter. Returns a dictionary with the
## center points as the key and an array of the Character members as the value.
func find_group_index_centers(x_count: int) -> Dictionary[int, Array]:
	var group_centers: Dictionary[int, Array] = {}
	for g: Array[Character] in _groups.values():
		var center: Vector3 = Vector3.ZERO
		for c: Character in g:
			center += c.map_coordinate.get_cube_coord()
		center /= g.size()
		group_centers[HexUtil.cube_to_index(center.round(), x_count)] = g
	return group_centers


## Determines the characters that are grouped together. Returns if any groups
## are present amongst the characters.
## Reference: https://en.wikipedia.org/wiki/DBSCAN
func _determine_groups(characters: Array[Character]) -> bool:
	# Tracks the evaluation status of each character
	var c_status: Dictionary[int, groupStatus] = {}
	for c: Character in characters:
		c_status[c.get_instance_id()] = groupStatus.UNDEFINED
	
	var group_count: int = 0
	for c: Character in characters:
		var c_id: int = c.get_instance_id()
		# Previously processed
		if c_status[c_id] != groupStatus.UNDEFINED:
			continue
		var neighbors: Array[Character] = _neighbors(c, characters)
		if neighbors.size() < min_group_size:
			c_status[c_id] = groupStatus.NOISE
			continue
		# Add core character to new group.
		group_count += 1
		_groups[group_count] = []
		_groups[group_count].append(c)
		c_status[c_id] = groupStatus.GROUPED
		for n: Character in neighbors:
			# Do not process original character
			if n == c:
				continue
			var n_id: int = n.get_instance_id()
			# Change noise to border point
			if c_status[n_id] == groupStatus.NOISE:
				_groups[group_count].append(n)
				c_status[n_id] = groupStatus.GROUPED
			# Previously processed
			if c_status[n_id] != groupStatus.UNDEFINED:
				continue
			_groups[group_count].append(n)
			c_status[n_id] = groupStatus.GROUPED
			var n_neighbors: Array[Character] = _neighbors(n, characters)
			if n_neighbors.size() >= min_group_size:
				neighbors.append_array(n_neighbors)
	return group_count > 0


## Helper function for _determine_groups. Determines the neighbors of a character
## based on their cube distance.
## Reference: https://en.wikipedia.org/wiki/DBSCAN
func _neighbors(
	reference_char: Character,
	characters: Array[Character]
) -> Array[Character]:
	var n: Array[Character] = []
	var ref_coord: Vector3 = reference_char.map_coordinate.get_cube_coord()
	for c: Character in characters:
		var c_coord: Vector3 = c.map_coordinate.get_cube_coord()
		if abs(HexUtil.cube_dist(ref_coord, c_coord)) <= max_distance:
			n.append(c)
	return n
