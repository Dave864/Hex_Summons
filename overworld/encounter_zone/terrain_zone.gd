@tool
class_name TerrainZone
extends Area3D
## Manages what maps will be used in an encounter when the OverworldAvatar is in
## this area.


## The name of the node that tracks the travel points used to determine
## where an EncounterSpawn can travel to.
const TRAVEL_ZONES_NAME := "TravelPointZones"
## The name of the node that records the spawn areas assigned to this zone.
const SPAWN_AREAS_NAME := "SpawnAreas"

## Files paths to the possible map selections for this zone.
@export_dir var maps : Array[String]

## The currently tracked travel points.
var travel_point_zones: TravelPointZones = null

## The scene tree root.
var _scene_root : Node:
	get():
		return get_tree().edited_scene_root


## Creates the relevant child nodes if they are not present.
func _ready() -> void:
	_ready_collision_shape()
	if has_node(TRAVEL_ZONES_NAME):
		travel_point_zones = get_node(TRAVEL_ZONES_NAME) as TravelPointZones
	else:
		travel_point_zones = TravelPointZones.new()
		add_child(travel_point_zones)
		travel_point_zones.name = TRAVEL_ZONES_NAME
		if Engine.is_editor_hint():
			travel_point_zones.set_owner(_scene_root)
	_ready_node3d(SPAWN_AREAS_NAME)
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


## Creates a Node3D of the specified name if it is not already present.
func _ready_node3d(node_name: String) -> void:
	if not has_node(node_name):
		var node := Node3D.new()
		add_child(node)
		if Engine.is_editor_hint():
			node.set_owner(_scene_root)
		node.name = node_name


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
