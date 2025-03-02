extends MeshInstance
class_name HexHighlighter
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
}

var hl_option: int = Option.NONE setget set_option


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Activates the highlighter based on the _is_selectable flag.
func set_option(o: int) -> void:
	hl_option = o
	match hl_option:
		Option.PLAYER:
			_set_highlighter_color(Constants.COLOR_CHARACTER_ORIGIN)
			show()
		Option.ALLY:
			_set_highlighter_color(Constants.COLOR_ALLY_ORIGIN)
			show()
		Option.RANGE:
			_set_highlighter_color(Constants.COLOR_AREA_RANGE)
			show()
		Option.EFFECT_ORIGIN:
			_set_highlighter_color(Constants.COLOR_EFFECT_ORIGIN)
			show()
		Option.EFFECT_RANGE:
			_set_highlighter_color(Constants.COLOR_EFFECT_RANGE)
			show()
		Option.TARGET:
			_set_highlighter_color(Constants.COLOR_TARGET_SELECT)
			show()
		_:
			hide()


# Changes the color of the tile highlighter
func _set_highlighter_color(color: Color) -> void:
	var m: Material = $Highlighter.get_surface_material(0)
	m.albedo_color = color
	$Highlighter.set_surface_material(0, m)
