@tool
class_name TerrainZone
extends Area3D
## Manages what maps will be used in an encounter when the OverworldAvatar is in
## this area.


## The name of the node that tracks the points of interest used to determine
## where an EncounterSpawn can travel to.
const INTEREST_POINTS_NAME := "InterestPoints"
## The name of the node that records the spawn areas assigned to this zone.
const SPAWN_AREAS_NAME := "SpawnAreas"

## Files paths to the possible map selections for this zone.
@export_dir var maps : Array[String]

## The currently tracked points of interest.
var points_of_interest : PackedVector3Array

## The scene tree root.
var _scene_root : Node:
	get():
		return get_tree().edited_scene_root


## Creates a new CollisionShape if none is present.
func _ready() -> void:
	_ready_collision_shape()
	_ready_node(INTEREST_POINTS_NAME)
	_get_points_of_interest()
	_ready_node(SPAWN_AREAS_NAME)
	_set_terrain_for_spawn_areas()


## Establishes the collision layers of a newly created zone.
func _init() -> void:
	set_collision_layer_value(Constants.DEFAULT_LAYER, false)
	set_collision_layer_value(Constants.MAP_LAYER, true)
	set_collision_mask_value(Constants.DEFAULT_LAYER, false)
	set_collision_mask_value(Constants.PLAYER_LAYER, true)
	set_collision_mask_value(Constants.ENEMY_LAYER, true)


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


## Creates a Node of the specified name if it is not already present.
func _ready_node(node_name: String) -> void:
	if not has_node(node_name):
		var node := Node.new()
		add_child(node)
		if Engine.is_editor_hint():
			node.set_owner(_scene_root)
		node.name = node_name


## Gets the positions for the assinged points of interest.
func _get_points_of_interest() -> void:
	for point: Node in get_node(INTEREST_POINTS_NAME).get_children():
		if point is Marker3D:
			points_of_interest.append(point.global_position)


## Goes through all assigned SpawnAreas and sets their terrain zone.
func _set_terrain_for_spawn_areas() -> void:
	# Terrain zone is not needed for the running of tools logic for SpawnArea
	# nodes.
	if Engine.is_editor_hint():
		return
	var areas_container: Node = get_node(SPAWN_AREAS_NAME)
	for area: Node in areas_container.get_children():
		if area is SpawnArea:
			area.set_terrain_zone(self)


## Randomly selects one of the map paths of this zone.
func select_random_map_path() -> String:
	var selected_index := randi_range(0, maps.size() - 1)
	return maps[selected_index]
