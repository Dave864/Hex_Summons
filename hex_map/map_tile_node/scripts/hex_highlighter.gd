class_name HexHighlighter
extends MeshInstance3D
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

const COLOR_AREA_RANGE: Color = Color.BLUE
const COLOR_CHARACTER_ORIGIN: Color = Color.AQUA
const COLOR_ALLY_ORIGIN: Color = Color.DODGER_BLUE
const COLOR_EFFECT_RANGE: Color = Color.ORANGE
const COLOR_EFFECT_ORIGIN: Color = Color.YELLOW
const COLOR_TARGET_SELECT: Color = Color.RED
const COLOR_MOVE_SELECT: Color = Color.YELLOW
const COLOR_GRAY_SELECT: Color = Color.GRAY

var _hl_option: int: get = get_option, set = set_option

@onready var base_render_priority: int = mesh.surface_get_material(0).render_priority


# Called when the node enters the scene tree for the first time.
func _ready():
	set_option(Option.NONE)


# Sets the color based on the option. Hides the highlighter if the option is NONE.
func set_option(hl_option: int) -> void:
	mesh.surface_get_material(0).render_priority = base_render_priority
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
			get_surface_override_material(0).render_priority = base_render_priority + 1
			show()
		Option.EFFECT_RANGE:
			_set_highlighter_color(COLOR_EFFECT_RANGE)
			show()
		Option.TARGET:
			_set_highlighter_color(COLOR_TARGET_SELECT)
			get_surface_override_material(0).render_priority = base_render_priority + 1
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
func set_highlighter_transparency(f: float) -> void:
	var m: StandardMaterial3D = mesh.surface_get_material(0)
	f = 0.0 if f < 0.0 else 1.0 if f > 1.0 else f
	m.albedo_color.a = f
	set_surface_override_material(0, m)


# Changes the color of the tile highlighter
func _set_highlighter_color(color: Color) -> void:
	var m: StandardMaterial3D = mesh.surface_get_material(0)
	m.albedo_color = color
	set_surface_override_material(0, m)
