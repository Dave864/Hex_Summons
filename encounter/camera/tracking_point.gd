class_name TrackingPoint
extends Marker3D
## A point that moves gradually to a specified location.
##
## Moves towards a destination point at a specified rate. The rate can be linear
## or decaying, where the point slows down as it reached the destination.


## The lowest possible value for speed.
const MIN_SPEED := 1.0
## The highest possible value for speed.
const MAX_SPEED := 100.0
## The increment that speed changes.
const SPEED_STEP := 0.1

## The different types of movement.
enum MovementType {
	SNAP, ## The movement to the destination is instant.
	LINEAR, ## The speed is constant.
	DECAYING, ## The speed decreases as the destination nears.
}

## How the point should move towards the destination.
@export var movement_type := MovementType.LINEAR
## The movement speed of the point.
@export_range(MIN_SPEED, MAX_SPEED, SPEED_STEP, "exp") var speed: float:
	set(value):
		speed = value
		_decay_rate = (speed - MIN_SPEED + SPEED_STEP) / (MAX_SPEED - MIN_SPEED)

## Flag that indicates if the destination has been reached.
var _destination_reached: bool = true
## The distance to the destination.
var _distance_to_destination: float = 0.0
## The rate at which speed decays when using DECAYING movement.
var _decay_rate: float = (speed - MIN_SPEED + SPEED_STEP) / (MAX_SPEED - MIN_SPEED)

## The starting point for any movement step.
@onready var _start_point: Vector3 = self.position
## The destination the point moves to.
@onready var _destination: Vector3 = self.position


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _destination_reached:
		return
	match movement_type:
		MovementType.SNAP:
			_snap_movement()
		MovementType.LINEAR:
			_linear_movement(delta)
		MovementType.DECAYING:
			_decaying_movement()
		_:
			pass


## Changes the destination.
func update_destination(new_destination: Vector3) -> void:
	_destination = new_destination
	_distance_to_destination = position.distance_squared_to(_destination)
	_destination_reached = new_destination.is_equal_approx(position)
	_start_point = position


## The logic for handling snap movement.
func _snap_movement() -> void:
	position = _destination
	_destination_reached = true
	_start_point = position


## The logic for handling linear movement.
func _linear_movement(delta: float) -> void:
	var updated_position: Vector3 = (
		position + (position.direction_to(_destination) * speed * delta)
	)
	var cur_distance: float = updated_position.distance_squared_to(_start_point)
	# Snap position to destination if movement overshoots.
	position = (
		_destination if cur_distance > _distance_to_destination
		else updated_position
	)
	_destination_reached = position.is_equal_approx(_destination)


## The logic for handling decaying movement.
func _decaying_movement() -> void:
	position = position.lerp(_destination, _decay_rate)
	_destination_reached = position.is_equal_approx(_destination)
