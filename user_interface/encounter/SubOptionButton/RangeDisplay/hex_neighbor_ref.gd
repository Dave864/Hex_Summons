class_name HexNeighborRef
extends Object
"""
Keeps track of the adjacenct indexes for a given index. Meant to be used in a
matrix representing a grid of hex tiles.
"""


const EMPTY_REF: Vector2 = Vector2(-1, -1)

# X coordinate represents the column, Y coordinate represents the row.
var index_pos: Vector2 = Vector2.ZERO

# References the hex nodes that are adjacent to this one.
#  0  / \  1
#  5 |   | 2
#  4  \ /  3
var _neighbors: Array = [
		EMPTY_REF,
		EMPTY_REF,
		EMPTY_REF,
		EMPTY_REF,
		EMPTY_REF,
		EMPTY_REF
]


func get_neighbors() -> Array:
	return _neighbors


func get_neighbor(n: int) -> Vector2:
	assert(
			n >= 0 and n < 6,
			"Attempted to get invalid neighbor from HexNeighborRef."
	)
	return _neighbors[n]


func _init(new_index: Vector2, row_count: int, col_count: int) -> void:
	index_pos = new_index
	_set_neighbors(row_count, col_count)


# Sets the neighbors based on the size of the matrix.
func _set_neighbors(row_count: int, col_count: int) -> void:
	_neighbors[2] = (
			Vector2(index_pos.x + 1, index_pos.y) if index_pos.x < col_count - 1
			else EMPTY_REF
	)
	_neighbors[5] = (
			Vector2(index_pos.x - 1, index_pos.y) if index_pos.x > 0
			else EMPTY_REF
	)
	# Index is on top row.
	if index_pos.y == 0:
		_set_top_row_neighbors()
	# Index is on bottom row.
	elif index_pos.y == row_count - 1:
		_set_bottom_row_neighbors(col_count)
	# Index is not in border row.
	else:
		_set_neighbors_middle(col_count)


# Sets the neigbors when the index_pos is in the top row.
func _set_top_row_neighbors() -> void:
	_neighbors[0] = EMPTY_REF
	_neighbors[1] = EMPTY_REF
	_neighbors[3] = Vector2(index_pos.x, index_pos.y + 1)
	_neighbors[4] = (
			EMPTY_REF if index_pos.x == 0
			else Vector2(index_pos.x - 1, index_pos.y + 1)
	)


# Sets the neigbors when the index_pos is on the bottom row.
func _set_bottom_row_neighbors(col_count: int)-> void:
	_neighbors[3] = EMPTY_REF
	_neighbors[4] = EMPTY_REF
	
	if int(index_pos.y) % 2 == 0:
		_neighbors[0] = (
				EMPTY_REF if index_pos.x == 0
				else Vector2(index_pos.x - 1, index_pos.y - 1)
		)
		_neighbors[1] = Vector2(index_pos.x, index_pos.y - 1)
	else:
		_neighbors[0] = Vector2(index_pos.x - 1, index_pos.y - 1)
		_neighbors[1] = (
				EMPTY_REF if index_pos.x == col_count -1
				else Vector2(index_pos.x + 1, index_pos.y - 1)
		)


# Sets the neigbors when the index_pos is in the middle of the map.
func _set_neighbors_middle(col_count: int) -> void:
	if int(index_pos.y) % 2 == 0:
		_neighbors[0] = (
				EMPTY_REF if index_pos.x == 0
				else Vector2(index_pos.x - 1, index_pos.y - 1)
		)
		_neighbors[1] = Vector2(index_pos.x, index_pos.y - 1)
		_neighbors[3] = Vector2(index_pos.x, index_pos.y + 1)
		_neighbors[4] = (
				EMPTY_REF if index_pos.x == 0
				else Vector2(index_pos.x - 1, index_pos.y + 1)
		)
	else:
		_neighbors[0] = Vector2(index_pos.x, index_pos.y - 1)
		_neighbors[1] = (
				EMPTY_REF if index_pos.x == col_count - 1
				else Vector2(index_pos.x + 1, index_pos.y - 1)
		)
		_neighbors[3] = (
				EMPTY_REF if index_pos.x == col_count - 1
				else Vector2(index_pos.x + 1, index_pos.y + 1)
		)
		_neighbors[4] = Vector2(index_pos.x, index_pos.y + 1)
