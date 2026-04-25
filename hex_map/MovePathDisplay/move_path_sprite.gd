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
## The texture for a corner path.
const CORNER_TEXTURE := preload("res://hex_map/MovePathDisplay/path_corner.atlastex")
## The size of the pixel for the sprite.
const PIXEL_SIZE := 0.0228
## The modulate color of the sprite.
const MOD_COLOR := HexHighlighter.COLOR_ORIGIN_CHARACTER
## The alpha level (transparency) of the sprite.
const ALPHA_VALUE := 0.4

## The type of path the sprite shows.
enum PathType {
	END, ## An arrow pointing to the movement destination.
	STRAIGHT, ## A straight path.
	BEND_LEFT, ## A path that bends left at 2 * pi / 3 radians.
	BEND_RIGHT, ## A path that bends right at 2 * pi / 3 radians.
	CORNER_LEFT, ## A path that bends left at pi / 3 radians.
	CORNER_RIGHT, ## A path that bends right at pi / 3 radians.
}

## The type of path the sprite shows.
@export var path: PathType = PathType.END:
	set(value):
		path = value
		_set_path_texture()


## Sets the parameters of the sprite.
func ready() -> void:
	_set_parameters()


## Creates a new sprite for the specified path.
func _init(
	type: PathType = PathType.END,
	entry_edge: HexUtil.HexDirection = HexUtil.HexDirection.UPPER_LEFT
) -> void:
	path = type
	_set_parameters()
	set_move_entry_edge(entry_edge)


## Updates the orientation of the sprite to match the hex edge the path enters
## from.
func set_move_entry_edge(entry_edge: HexUtil.HexDirection) -> void:
	match entry_edge:
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
	flip_h = false
	match path:
		PathType.END:
			texture = END_TEXTURE
		PathType.STRAIGHT:
			texture = STRAIGHT_TEXTURE
		PathType.BEND_LEFT:
			texture = BEND_TEXTURE
		PathType.BEND_RIGHT:
			texture = BEND_TEXTURE
			flip_h = true
		PathType.CORNER_LEFT:
			texture = CORNER_TEXTURE
		PathType.CORNER_RIGHT:
			texture = CORNER_TEXTURE
			flip_h = true


## Sets various parameters of the sprite to match constants.
func _set_parameters() -> void:
	pixel_size = PIXEL_SIZE
	axis = Vector3.Axis.AXIS_Y
	modulate = MOD_COLOR
	modulate.a = ALPHA_VALUE
	render_priority = -1
	texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
