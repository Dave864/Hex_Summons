@tool
class_name TerrainZone
extends Area3D
## Manages what maps will be used in an encounter when the OverworldAvatar is in
## this area.


## The name of the node that tracks the travel points used to determine
## where an EncounterSpawn can travel to.
const TRAVEL_POINTS_NAME := "TravelPoints"
## The name of the node that records the spawn areas assigned to this zone.
const SPAWN_AREAS_NAME := "SpawnAreas"

## Files paths to the possible map selections for this zone.
@export_dir var maps : Array[String]

## The currently tracked travel points.
var travel_points : PackedVector3Array

## The scene tree root.
var _scene_root : Node:
	get():
		return get_tree().edited_scene_root


## Creates a new CollisionShape if none is present.
func _ready() -> void:
	_ready_collision_shape()
	_ready_node3d(TRAVEL_POINTS_NAME)
	_get_travel_points()
	_ready_node3d(SPAWN_AREAS_NAME)
	_set_terrain_for_spawn_areas()


## Establishes the collision layers of a newly created zone.
func _init() -> void:
	set_collision_layer_value(Constants.DEFAULT_LAYER, false)
	set_collision_layer_value(Constants.MAP_LAYER, true)
	set_collision_mask_value(Constants.DEFAULT_LAYER, false)
	set_collision_mask_value(Constants.PLAYER_LAYER, true)
	set_collision_mask_value(Constants.ENEMY_LAYER, true)


## Gets a random travel point.
func get_random_travel_point() -> Vector3:
	var selection_index := randi() % travel_points.size()
	return travel_points[selection_index]


## Gets a random travel point that is within a given range of a reference
## point. Returns the closest point if no travel points are within range.
func get_random_travel_point_in_range(
	reference: Vector3,
	range_limit: float
) -> Vector3:
	var lambda_1 = func is_smaller(dist_sq: float, shortest: float) -> bool:
		return dist_sq < shortest
	var lambda_2 = func is_in_range(dist_sq: float, limit: float) -> bool:
		return dist_sq <= pow(limit, 2.0)
	return _get_random_travel_point_helper(
			reference,
			range_limit,
			INF,
			lambda_1,
			lambda_2
	)


## Gets a random travel point that fall outside a given range of a reference
## point. Can specify whether to default to the closest or farthest point if
## all points are within range.
func get_random_travel_point_beyond_range(
	reference: Vector3,
	range_limit: float,
	default_farthest: bool = true
) -> Vector3:
	var lambda_1 := func compare(dist_sq: float, value: float) -> bool:
		return value < dist_sq if default_farthest else value > dist_sq
	var lambda_2 := func outside_of_range(dist_sq: float, limit: float) -> bool:
		return dist_sq > pow(limit, 2.0)
	return _get_random_travel_point_helper(
			reference,
			range_limit,
			0.0 if default_farthest else INF,
			lambda_1,
			lambda_2
	)


## Creates a new collision shape if none is already present.
func _ready_collision_shape() -> void:
	if get_shape_owners().size() == 0:
		var collision_shape := CollisionShape3D.new()
		add_child(collision_shape)
		if Engine.is_editor_hint():
			collision_shape.set_owner(_scene_root)
		collision_shape.name = "CollisionShape3D"
		collision_shape.debug_color = Color.YELLOW
		collision_shape.debug_fill = false
		collision_shape.shape = BoxShape3D.new()


## Creates a Node3D of the specified name if it is not already present.
func _ready_node3d(node_name: String) -> void:
	if not has_node(node_name):
		var node := Node3D.new()
		add_child(node)
		if Engine.is_editor_hint():
			node.set_owner(_scene_root)
		node.name = node_name


## Gets the positions for the assinged travel points.
func _get_travel_points() -> void:
	for point: Node in get_node(TRAVEL_POINTS_NAME).get_children():
		if point is Marker3D:
			travel_points.append(point.global_position)


## Helper for functions that get a random travel point based off some range
## relative to a reference point. Gets a random travel point using the specified
## comparison operations.
func _get_random_travel_point_helper(
	reference: Vector3,
	range_limit: float,
	starting_comparison: float,
	default_comparator: Callable,
	update_comparator: Callable
) -> Vector3:
	var valid_points: PackedVector3Array = []
	var comparison_distance := starting_comparison
	var selected: Vector3
	for point: Vector3 in travel_points:
		var distance_squared := point.distance_squared_to(reference)
		if default_comparator.call(comparison_distance, distance_squared):
			comparison_distance = distance_squared
			selected = point
		if update_comparator.call(distance_squared, range_limit):
			valid_points.append(point)
	if valid_points.size() > 0:
		var i := randi() % valid_points.size()
		selected = valid_points[i]
	return selected


## Goes through all assigned SpawnAreas and sets their terrain zone.
func _set_terrain_for_spawn_areas() -> void:
	# Terrain zone is not needed for the running of tools logic for SpawnArea
	# nodes.
	if Engine.is_editor_hint():
		return
	var areas_container: Node3D = get_node(SPAWN_AREAS_NAME)
	for area: Node in areas_container.get_children():
		if area is SpawnArea:
			area.set_terrain_zone(self)


## Randomly selects one of the map paths of this zone.
func select_random_map_path() -> String:
	var selected_index := randi_range(0, maps.size() - 1)
	return maps[selected_index]
