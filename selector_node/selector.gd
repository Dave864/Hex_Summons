class_name Selector
extends Node
## Handles the selection of map tiles for player movement and actions.


## Indicates that the selector has confirmed the details of a spawn action for
## a summon character.
signal spawn_action_confirmed(name, emission_position)
## Indicates that the encounter camera should focus on a new point.
signal new_focus_point(new_position)
## Indicates if the camera focus is locked to a point.
signal camera_focus_locked(is_locked)

## The MapTile that was last passed over.
var tile_hovered: MapTile = null
## Describes which hex vertex is the top with respect to the camera
var top_vertex: int = 0
## Reference to the active character (player or summon).
var active_character: Character = null
## Reference to the player characters in the current encounter.
var players_ref: Array[Character] = []
## Reference to the enemy characer in the current encounter.
var enemies_ref: Array[Character] = []
## Reference to the HexMap of the current encounter map.
var hex_map: HexMap = null

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


## Emits the spawn_action_confirmed signal with the summon name and emission
## position.
func emit_spawn_action_confirmed(
	summon_name: String,
	emission_position: Vector3
) -> void:
	emit_signal("spawn_action_confirmed", summon_name, emission_position)


## Emits the camera_reposition signal with the position the encounter camera
## should point to.
func emit_new_focus_point(new_position: Vector3) -> void:
	emit_signal("new_focus_point", new_position)


## Emits the camera_focus_locked signal, indicating that the focus is locked.
func emit_camera_focus_locked() -> void:
	emit_signal("camera_focus_locked", true)


## Emits the camera_focus_locked signal, indicating that the focus is unlocked.
func emit_camera_focus_unlocked() -> void:
	emit_signal("camera_focus_locked", false)


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
