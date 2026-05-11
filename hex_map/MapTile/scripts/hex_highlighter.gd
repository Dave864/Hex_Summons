class_name HexHighlighter
extends MeshInstance3D
## Hexagonal shape used to represent available options in a HexMap scene.


## Specifies the highlight option for the highlighter.
enum Option {
	NONE, ## No highlight.
	ORIGIN_PLAYER, ## The origin point for an active player character.
	ORIGIN_ALLY, ## The origin point for an ally character.
	ORIGIN_ENEMY, ## The origin point for an enemy character.
	ORIGIN_EFFECT, ## The origin point for the effect range of an action.
	RANGE_MOVE, ## An area tile for movement.
	RANGE_SOURCE, ## An area tile for the source range of an action.
	RANGE_EFFECT, ## An area tile for the effect range of an action.
	TARGET_ALLY, ## A tile with an ally within an effect range.
	TARGET_ENEMY, ## A tile with an enemy within an effect range.
	SELECT_MOVE, ## The tile under consideration for movement.
	SELECT_GRAY, ## An indication that a tile is highlighted.
}

## The color for general displays of range.
const COLOR_AREA_RANGE := Color.BLUE
## The color for the display of movement range.
const COLOR_RANGE_MOVE := Color.BLUE
## The color for the display of an action's source range.
const COLOR_RANGE_SOURCE := Color.PURPLE
## The color for highlighting the effect range.
const COLOR_RANGE_EFFECT := Color.ORANGE
## The color for the position of the character in focus.
const COLOR_ORIGIN_CHARACTER := Color.AQUA
## The color for highlighting ally character positions.
const COLOR_ORIGIN_ALLY := Color.DEEP_SKY_BLUE
## The color for highlighting enemy character positions.
const COLOR_ORIGIN_ENEMY := Color.RED
## The color for highlighting the origin point of an effect.
const COLOR_ORIGIN_EFFECT := Color.YELLOW
## The color for highlighting an ally target.
const COLOR_TARGET_ALLY := Color.GREEN
## The color for highlighting an enemy target.
const COLOR_TARGET_ENEMY := Color.RED
## The color for highlighting a selected movement tile.
const COLOR_SELECT_MOVE := Color.YELLOW
## Grey color.
const COLOR_SELECT_GRAY := Color.GRAY

## The map tile whose height will be used for determining render priority.
@export var height_reference: MapTile = null

## The current highlight option.
var _hl_option: Option
## The material used for the highlight.
var _hightlight_material: Material:
	get:
		return mesh.surface_get_material(0)
## The baseline render priority for the highlight. Adds double the height of
## the reference to allow for render priority adjustments to not impact
## highlights at different elevations. 
@onready var _base_render_priority: int = (
	_hightlight_material.render_priority + (2 * height_reference.height)
)


## Called when the node enters the scene tree for the first time.
func _ready():
	set_option(Option.NONE)


## Sets the color based on the option. Hides the highlighter if the option is
## NONE.
func set_option(hl_option: Option) -> void:
	_set_render_priority(_base_render_priority)
	_hl_option = hl_option
	match _hl_option:
		Option.ORIGIN_PLAYER:
			_set_highlighter_color(COLOR_ORIGIN_CHARACTER)
			show()
		Option.ORIGIN_ALLY:
			_set_highlighter_color(COLOR_ORIGIN_ALLY)
			show()
		Option.ORIGIN_ENEMY:
			_set_highlighter_color(COLOR_ORIGIN_ENEMY)
			show()
		Option.RANGE_MOVE:
			_set_highlighter_color(COLOR_AREA_RANGE)
			show()
		Option.ORIGIN_EFFECT:
			_set_highlighter_color(COLOR_ORIGIN_EFFECT)
			_set_render_priority(_base_render_priority + 1)
			show()
		Option.RANGE_EFFECT:
			_set_highlighter_color(COLOR_RANGE_EFFECT)
			show()
		Option.RANGE_SOURCE:
			_set_highlighter_color(COLOR_RANGE_SOURCE)
			show()
		Option.TARGET_ALLY:
			_set_highlighter_color(COLOR_TARGET_ALLY)
			_set_render_priority(_base_render_priority + 1)
			show()
		Option.TARGET_ENEMY:
			_set_highlighter_color(COLOR_TARGET_ENEMY)
			_set_render_priority(_base_render_priority + 1)
			show()
		Option.SELECT_MOVE:
			_set_highlighter_color(COLOR_SELECT_MOVE)
			show()
		Option.SELECT_GRAY:
			_set_highlighter_color(COLOR_SELECT_GRAY)
			show()
		_:
			hide()


## Gets the option currently active.
func get_option() -> Option:
	return _hl_option


## Sets the transparency value of the highlighter. Accepts a value between 0 and
## 1.0.
func set_highlighter_transparency(f: float) -> void:
	f = 0.0 if f < 0.0 else 1.0 if f > 1.0 else f
	_hightlight_material.albedo_color.a = f


## Adjusts the render priority of the highlighter by the specified amount.
func offset_render_priority(offset: int) -> void:
	_set_render_priority(_hightlight_material.render_priority + offset)


## Resets the render priority to its value as determined by the highlight
## option.
func reset_render_priority() -> void:
	set_option(_hl_option)


## Changes the color of the tile highlighter, keeping the original alpha value.
func _set_highlighter_color(color: Color) -> void:
	var alpha: float = _hightlight_material.albedo_color.a
	_hightlight_material.albedo_color = color
	_hightlight_material.albedo_color.a = alpha


## Sets the render priority of the material and any nested materials. The
## priorities are set to the same value.
func _set_render_priority(priority: int) -> void:
	_hightlight_material.render_priority = priority
	var next_material: Material = _hightlight_material.next_pass
	while next_material != null:
		next_material.render_priority = priority
		next_material = next_material.next_pass
