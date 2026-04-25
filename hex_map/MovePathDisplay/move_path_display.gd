class_name MovePathDisplay
extends Node
## Creates a display for a movement path.
##
## Creates sprites for each point on the path, orienting them to match the
## path's direction.


## The sprite that will be used for the end of the path.
@onready var _end_sprite: MovePathSprite = $EndPathSprite
## Container tracking the rest of the path sprites.
@onready var _path_sprites: Node = $PathSprites


## Creates and shows the display for the given path.
func create_display(move_path: PackedVector3Array) -> void:
	# To mitigate visual issues that come with updating the sprites.
	hide()
	_add_missing_sprites(move_path)
	for i in range(move_path.size() - 1, 0, -1):
		var current_point := Vector2(move_path[i].x, move_path[i].z)
		var prior_point := Vector2(move_path[i - 1].x, move_path[i - 1].z)
		var entry_direction := current_point.direction_to(prior_point)
		var entry_hex_direction := HexUtil.get_hex_direction(entry_direction)
		if i == move_path.size() - 1:
			_end_sprite.set_move_entry_direction(entry_hex_direction)
			_end_sprite.position = move_path[i]
			_end_sprite.show()
		else:
			var sprite := _path_sprites.get_child(i) as MovePathSprite
			sprite.set_move_entry_direction(entry_hex_direction)
			var next_point := Vector2(move_path[i + 1].x, move_path[i + 1].z)
			var exit_direction := next_point.direction_to(current_point)
			_set_path_type(sprite, entry_direction, exit_direction)
			sprite.position = move_path[i]
			sprite.show()


## Hides the sprites for the path.
func hide() -> void:
	_end_sprite.hide()
	for sprite: MovePathSprite in _get_path_sprites():
		sprite.hide()


## Creates new MovePathSprites to match the size of the given path.
func _add_missing_sprites(move_path: PackedVector3Array) -> void:
	var sprite_count_difference: int = (
		move_path.size() - 1 - _path_sprites.get_child_count()
	)
	if sprite_count_difference <= 0:
		return
	for i in sprite_count_difference:
		var new_sprite := MovePathSprite.new()
		new_sprite.hide()
		_path_sprites.add_child(new_sprite)


## Sets the path type for the given sprite based off of where the path enters
## and exits the segment.
func _set_path_type(
	sprite: MovePathSprite,
	entry_direction: Vector2,
	exit_direction: Vector2
) -> void:
	var path_type: MovePathSprite.PathType = MovePathSprite.PathType.STRAIGHT
	#if entry_direction.is_equal_approx(exit_direction):
		#path_type = MovePathSprite.PathType.STRAIGHT
	#else:
		#printerr("Movement path goes back on itself.")
		#path_type = MovePathSprite.PathType.STRAIGHT
	sprite.path = path_type


## Gets the sprites in the PathSprites node.
func _get_path_sprites() -> Array[MovePathSprite]:
	var sprites: Array[MovePathSprite] = []
	for sprite: Node in _path_sprites.get_children():
		sprites.append(sprite as MovePathSprite)
	return sprites
