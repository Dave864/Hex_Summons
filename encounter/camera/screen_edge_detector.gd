@tool
class_name ScreenEdgeDetector
extends Control
## Defines the area that is considered the edge of the screen. Used for mouse
## and keyboard inputs.
##
## Detects when the mouse has entered the defined edge area. Determines the
## direction from the center of the screen to the hovered point in the edge area.


## Indicates that the edge of the screen is entered.
signal edge_hit

## The minimum distance that can be defined as the edge.
const MIN_DIST := 1.0
## The maximum distance that can be defined as the edge.
const MAX_DIST := 200.0
## The increment step for adjusting the edge distance.
const DIST_STEP := 0.01

## The distance from the top of the screen to the end of the top edge area.
@export_range(MIN_DIST, MAX_DIST, DIST_STEP) var top_edge = 20.0:
	set(value):
		if not is_node_ready():
			return
		top_edge = value
		_adjust_top_positions()
## The distance from the bottom of the screen to the end of the bottom edge area.
@export_range(MIN_DIST, MAX_DIST, DIST_STEP) var bottom_edge = 20.0:
	set(value):
		if not is_node_ready():
			return
		bottom_edge = value
		_adjust_bottom_positions()
## The distance from the left of the screen to the end of the left edge area.
@export_range(MIN_DIST, MAX_DIST, DIST_STEP) var left_edge = 20.0:
	set(value):
		if not is_node_ready():
			return
		left_edge = value
		_adjust_left_positions()
## The distance from the right of the screen to the end of the right edge area.
@export_range(MIN_DIST, MAX_DIST, DIST_STEP) var right_edge = 20.0:
	set(value):
		if not is_node_ready():
			return
		right_edge = value
		_adjust_right_positions()

## Indicates that the mouse is within the edge area.
var _in_edge := false
## The direction from center to where the mouse is in the edge area.
var _direction := Vector2.ZERO
## The index position of a hex tile that is considered to be the top.
var _top_hex_vertex: int = 0

## The center of the detection area.
@onready var _center := Vector2(size.x / 2.0, size.y / 2.0)
## The detector for the top edge.
@onready var _top_detector: ReferenceRect = $DetectorTop
## The detector for the bottom edge.
@onready var _bottom_detector: ReferenceRect = $DetectorBottom
## The detector for the left edge.
@onready var _left_detector: ReferenceRect = $DetectorLeft
## The detector for the right edge.
@onready var _right_detector: ReferenceRect = $DetectorRight
## The detector for the top left corner.
@onready var _top_left_detector: ReferenceRect = $DetectorTopLeft
## The detector for the top right corner.
@onready var _top_right_detector: ReferenceRect = $DetectorTopRight
## The detector for the bottom left corner.
@onready var _bottom_left_detector: ReferenceRect = $DetectorBottomLeft
## The detector for the bottom right corner.
@onready var _bottom_right_detector: ReferenceRect = $DetectorBottomRight


## Connects the top_vertex_changed signal from SignalBus.
func _ready() -> void:
	_set_camera_cursor()
	SignalBus.connect(
			"top_vertex_changed",
			Callable(self, "_on_SignalBus_top_vertex_changed")
	)


## Calculates the direction from center to the mouse position when the mouse is
## within the edge area.
func _process(_delta: float) -> void:
	# Prevent issues when adding as packed scene to other scenes.
	if Engine.is_editor_hint():
		return
	if InputController.source_is_keymouse() and _in_edge:
		_direction = (MouseHandler.get_2d_position() - _center).normalized()
		emit_signal("edge_hit")


## Disables the ability to detect mouse movement.
func disable() -> void:
	_top_detector.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bottom_detector.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_left_detector.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_right_detector.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_top_left_detector.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_top_right_detector.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bottom_left_detector.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bottom_right_detector.mouse_filter = Control.MOUSE_FILTER_IGNORE


## Enables the ability to detect mouse movement.
func enable() -> void:
	_top_detector.mouse_filter = Control.MOUSE_FILTER_STOP
	_bottom_detector.mouse_filter = Control.MOUSE_FILTER_STOP
	_left_detector.mouse_filter = Control.MOUSE_FILTER_STOP
	_right_detector.mouse_filter = Control.MOUSE_FILTER_STOP
	_top_left_detector.mouse_filter = Control.MOUSE_FILTER_STOP
	_top_right_detector.mouse_filter = Control.MOUSE_FILTER_STOP
	_bottom_left_detector.mouse_filter = Control.MOUSE_FILTER_STOP
	_bottom_right_detector.mouse_filter = Control.MOUSE_FILTER_STOP


## Gets the normalized vector direction.
func get_direction_to_edge() -> Vector2:
	return _direction


## Gets the direction as a hex direction.
func get_hex_direction_to_edge() -> HexUtil.HexDirection:
	return HexUtil.get_hex_direction(_direction, _top_hex_vertex)


## Modify the dimensions of the edge detectors to match the top edge dimension.
func _adjust_top_positions() -> void:
	_top_detector.size.y = top_edge
	_top_left_detector.size.y = top_edge
	_top_right_detector.size.y = top_edge
	var old_pos: float = _left_detector.position.y
	_left_detector.position.y = top_edge
	_left_detector.size.y += old_pos - top_edge
	old_pos = _right_detector.position.y
	_right_detector.position.y = top_edge
	_right_detector.size.y += old_pos - top_edge


## Modify the dimensions of the edge detectors to match the bottom edge dimension.
func _adjust_bottom_positions() -> void:
	var new_pos: float = size.y - bottom_edge
	_bottom_detector.size.y = bottom_edge
	_bottom_detector.position.y = new_pos
	_bottom_left_detector.size.y = bottom_edge
	_bottom_left_detector.position.y = new_pos
	_bottom_right_detector.size.y = bottom_edge
	_bottom_right_detector.position.y = new_pos
	_left_detector.size.y = new_pos - _left_detector.position.y
	_right_detector.size.y = new_pos - _right_detector.position.y


## Modify the dimensions of the edge detectors to match the left edge dimension.
func _adjust_left_positions() -> void:
	_left_detector.size.x = left_edge
	_top_left_detector.size.x = left_edge
	_bottom_left_detector.size.x = left_edge
	var position_diff: float = left_edge - _top_detector.position.x
	_top_detector.position.x = left_edge
	_top_detector.size.x -= position_diff
	position_diff = left_edge - _bottom_detector.position.x
	_bottom_detector.position.x = left_edge
	_bottom_detector.size.x -= position_diff


## Modify the dimensions of the edge detectors to match the right edge dimension.
func _adjust_right_positions() -> void:
	var new_pos: float = size.x - right_edge
	_right_detector.size.x = right_edge
	_right_detector.position.x = new_pos
	_top_right_detector.size.x = right_edge
	_top_right_detector.position.x = new_pos
	_bottom_right_detector.size.x = right_edge
	_bottom_right_detector.position.x = new_pos
	_top_detector.size.x = size.x - right_edge - _top_detector.position.x
	_bottom_detector.size.x = size.x - right_edge - _bottom_detector.position.x


## Sets the move cursor to reflect camera movement.
func _set_camera_cursor() -> void:
	var cursor_camera_image: CompressedTexture2D = load(
			"res://art/ui/mouse_cursor/cursor_camera.png"
	)
	Input.set_custom_mouse_cursor(cursor_camera_image, Input.CURSOR_MOVE)


## Gets the direction from screen center to the mouse position.
func _on_Detector_mouse_entered() -> void:
	_in_edge = true


## Stops tracking the mouse position.
func _on_Detector_mouse_exited() -> void:
	_in_edge = false
	_direction = Vector2.ZERO


## Updates the top hex vertex when the SignalBus indicates it has changed.
func _on_SignalBus_top_vertex_changed(new_top_vertex: int) -> void:
	_top_hex_vertex = new_top_vertex
