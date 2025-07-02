class_name HexHighlighter
extends MeshInstance
"""
Hexagonal shape used to represent available options in a HexMap scene.
"""


enum Option {
	NONE,
	PLAYER,
	ALLY,
	RANGE,
	EFFECT_RANGE,
	EFFECT_ORIGIN,
	TARGET,
	MOVE,
	GRAY,
}

const COLOR_AREA_RANGE: Color = Color.blue
const COLOR_CHARACTER_ORIGIN: Color = Color.aqua
const COLOR_ALLY_ORIGIN: Color = Color.dodgerblue
const COLOR_EFFECT_RANGE: Color = Color.orange
const COLOR_EFFECT_ORIGIN: Color = Color.gold
const COLOR_TARGET_SELECT: Color = Color.red
const COLOR_MOVE_SELECT: Color = Color.gold
const COLOR_GRAY_SELECT: Color = Color.gray

var _hl_option: int setget set_option, get_option


# Called when the node enters the scene tree for the first time.
func _ready():
	set_option(Option.NONE)


# Sets the color based on the option. Hides the highlighter if the option is NONE.
func set_option(hl_option: int) -> void:
	match hl_option:
		Option.PLAYER:
			_set_highlighter_color(COLOR_CHARACTER_ORIGIN)
			show()
		Option.ALLY:
			_set_highlighter_color(COLOR_ALLY_ORIGIN)
			show()
		Option.RANGE:
			_set_highlighter_color(COLOR_AREA_RANGE)
			show()
		Option.EFFECT_ORIGIN:
			_set_highlighter_color(COLOR_EFFECT_ORIGIN)
			show()
		Option.EFFECT_RANGE:
			_set_highlighter_color(COLOR_EFFECT_RANGE)
			show()
		Option.TARGET:
			_set_highlighter_color(COLOR_TARGET_SELECT)
			show()
		Option.MOVE:
			_set_highlighter_color(COLOR_MOVE_SELECT)
			show()
		Option.GRAY:
			_set_highlighter_color(COLOR_GRAY_SELECT)
			show()
		_:
			hide()


func get_option() -> int:
	return _hl_option


# Sets the transparency value of the highlighter. Accepts a value between 0 and 1.0.
func set_transparency(f: float) -> void:
	var m: SpatialMaterial = get_surface_material(0)
	f = 0.0 if f < 0.0 else 1.0 if f > 1.0 else f
	m.albedo_color.a = f
	set_surface_material(0, m)


# Changes the color of the tile highlighter
func _set_highlighter_color(color: Color) -> void:
	var m: SpatialMaterial = get_surface_material(0)
	m.albedo_color = color
	set_surface_material(0, m)
