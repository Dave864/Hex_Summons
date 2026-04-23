@tool
class_name MovePathSprite
extends Sprite3D
## A Sprite3D that shows the movement path for a single tile.
##
## Can show either an end, straight line, or bend. Can be rotated by increments
## of pi / 3 radians, corresponding to the angles of a hexagon.


## The texture for the end path.
const END_TEXTURE := preload("res://hex_map/MovePathDisplay/path_end.atlastex")
## The texture for the straight path.
const STRAIGHT_TEXTURE := preload("res://hex_map/MovePathDisplay/path_straight.atlastex")
## The texture for a bent path.
const BEND_TEXTURE := preload("res://hex_map/MovePathDisplay/path_bend.atlastex")
## The size of the pixel for the sprite.
const PIXEL_SIZE := 0.0227

## The type of path the sprite shows.
enum PathType {
	END, ## An arrow pointing to the movement destination.
	STRAIGHT, ## A straight path.
	LEFT_BEND, ## A path that bends left at 2 * pi / 3 radians.
	RIGHT_BEND, ## A path that bends right at 2 * pi / 3 radians.
}

## The type of path the sprite shows.
@export var path: PathType = PathType.END:
	set(value):
		path = value
		_set_path_texture()


## Creates a new sprite for the specified path.
func _init(type: PathType = PathType.END) -> void:
	path = type
	pixel_size = PIXEL_SIZE
	axis = Vector3.Axis.AXIS_Y
	modulate.a = 0.5
	texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
	set_move_entry_direction(HexUtil.HexDirection.UPPER_LEFT)


## Updates the orientation of the sprite to match the movement entry direction.
func set_move_entry_direction(entry_direction: HexUtil.HexDirection) -> void:
	match entry_direction:
		HexUtil.HexDirection.UPPER_LEFT:
			rotation.y = PI / 6.0
		HexUtil.HexDirection.UPPER_RIGHT:
			rotation.y = 11.0 * PI / 6.0
		HexUtil.HexDirection.RIGHT:
			rotation.y = 3.0 * PI / 2.0
		HexUtil.HexDirection.BOTTOM_RIGHT:
			rotation.y = 7.0 * PI / 6.0
		HexUtil.HexDirection.BOTTOM_LEFT:
			rotation.y = 5.0 * PI / 6.0
		HexUtil.HexDirection.LEFT:
			rotation.y = PI / 2.0


## Sets the texture based on the path type.
func _set_path_texture() -> void:
	match path:
		PathType.END:
			texture = END_TEXTURE
		PathType.STRAIGHT:
			texture = STRAIGHT_TEXTURE
		PathType.LEFT_BEND:
			texture = BEND_TEXTURE
			flip_h = true
		PathType.RIGHT_BEND:
			texture = BEND_TEXTURE
