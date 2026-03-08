class_name Selector
extends Node3D
## Hovers over tiles that are being focused on, indicating that the tile is
## in focus.


## How far above the hovered tile the selector is placed.
@export_range(0.01, 0.5, 0.01) var y_offset: float = 0.01

## The MapTile that was last passed over.
var tile_hovered: MapTile = null:
	set(value):
		tile_hovered = value
		position = tile_hovered.get_character_position()
		position.y += y_offset
## Describes which hex vertex is the top with respect to the camera
var top_vertex: int = 0

## Reference to a function that will update the map tile highlights. Different
## states will use different logic for updating the highlights.
var _update_selection_func: Callable: set = set_update_selection_func


func _ready() -> void:
	ErrorUtil.connect_signal(
			SignalBus,
			"top_vertex_changed",
			self,
			"_on_SignalBus_top_vertex_changed"
	)


## Sets the _update_selection_func.
func set_update_selection_func(new_func: Callable) -> void:
	_update_selection_func = new_func


## Gets the tile that the mouse last hovered over.
func _on_MapTile_mouse_hovered(new_tile: MapTile) -> void:
	if not _update_selection_func.is_null():
		_update_selection_func.call(new_tile)


## Updates the hovered tile to be the new focus point as determined by the
## encounter camera's screen edge detection.
func _on_EncounterCamera_focus_moved_by_edge(new_focus_tile: MapTile) -> void:
	if not _update_selection_func.is_null():
		_update_selection_func.call(new_focus_tile)


## Updates the relative top vertex when the camera changes orientation.
func _on_SignalBus_top_vertex_changed(new_top_vertex: int) -> void:
	top_vertex = new_top_vertex
