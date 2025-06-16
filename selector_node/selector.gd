class_name Selector
extends Node
"""
Moves around the map based on mouse movement or joystick input and detects
when a MapTile has been passed over.
"""


# Indicates a tile has been selected for movement.
signal move_tile_selected(tile_selected)
# Indicates that a given action needs the effect area displayed.
signal effect_area_required(action)

# The MapTile that was last passed over.
var tile_hovered: MapTile = null
# Describes which hex vertex is the top with respect to the camera
var top_vertex: int = 0

# Reference to the map tiles of the current encounter map.
var _map_tiles_ref: Array = [] setget set_map_tiles_ref, get_map_tiles_ref
# Reference to a function that will update the map tile highlights. Different
# states will use different logic for updating the highlights.
var _update_highlights_func: FuncRef = null setget set_update_highlights_func

# The current mouse position
onready var mouse_position: MousePosition = $MousePosition
# The collision are for the selector
onready var collision_area: Area = $CollisionArea


# Sets the reference to the map tiles.
func set_map_tiles_ref(map_tiles_ref: Array) -> void:
	_map_tiles_ref = map_tiles_ref


# Gets the map tiles reference.
func get_map_tiles_ref() -> Array:
	return _map_tiles_ref


# Sets the _update_highlights_func.
func set_update_highlights_func(new_func: FuncRef) -> void:
	_update_highlights_func = new_func


# Move the collision area to the mouse position.
func move_to_mouse_position() -> void:
	move_to_position(mouse_position.get_mouse_position())


# Move the collision area to the specified position.
func move_to_position(position: Vector3) -> void:
	collision_area.translation = position


# Emits the move_tile_selected signal.
func emit_move_tile_selected(tile_selected: MapTile) -> void:
	emit_signal("move_tile_selected", tile_selected)


# Emits the effect_area_required.
func emit_effect_area_required(action: Action) -> void:
	emit_signal("effect_area_required", action)


func _ready() -> void:
	ErrorUtil.connect_signal(
			SignalBus,
			"top_vertex_changed",
			self,
			"_on_SignalBus_top_vertex_changed"
	)


# Gets the tile that the mouse last hovered over.
func _on_MapTile_mouse_hovered(new_tile: MapTile) -> void:
	if _update_highlights_func != null:
		_update_highlights_func.call_func(new_tile)


# Updates the relative top vertex when the camera changes orientation.
func _on_SignalBus_top_vertex_changed(new_top_vertex: int) -> void:
	top_vertex = new_top_vertex
