@tool
class_name ScreenEdgeDetector
extends Control
## Defines the area that is considered the edge of the screen. Used for mouse
## and keyboard inputs.
##
## Detects when the mouse has entered the defined edge area. Determines the
## direction from the center of the screen to the hovered point in the edge area.


## The minimum distance that can be defined as the edge.
const MIN_DIST := 1.0
## The maximum distance that can be defined as the edge.
const MAX_DIST := 200.0
## The increment step for adjusting the edge distance.
const DIST_STEP := 0.01

## The distance from the top of the screen to the end of the top edge area.
@export_range(MIN_DIST, MAX_DIST, DIST_STEP) var top_edge = 20.0:
	set(value):
		top_edge = value
		_adjust_top_positions()
## The distance from the bottom of the screen to the end of the bottom edge area.
@export_range(MIN_DIST, MAX_DIST, DIST_STEP) var bottom_edge = 20.0:
	set(value):
		bottom_edge = value
		_adjust_bottom_positions()
## The distance from the left of the screen to the end of the left edge area.
@export_range(MIN_DIST, MAX_DIST, DIST_STEP) var left_edge = 20.0:
	set(value):
		left_edge = value
		_adjust_left_positions()
## The distance from the right of the screen to the end of the right edge area.
@export_range(MIN_DIST, MAX_DIST, DIST_STEP) var right_edge = 20.0:
	set(value):
		right_edge = value
		_adjust_right_positions()

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
