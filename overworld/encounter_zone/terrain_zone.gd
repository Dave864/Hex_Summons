@tool
class_name TerrainZone
extends Area3D
## Manages what maps will be used in an encounter when the OverworldAvatar is in
## this area.


## The name of the node that records the spawn areas assigned to this zone.
const SPAWN_AREAS_NAME := "SpawnAreas"

## Files paths to the possible map selections for this zone.
@export_dir var maps : Array[String]


## Creates a new CollisionShape if none is present.
func _ready() -> void:
	if get_shape_owners().size() == 0:
		var collision_shape := CollisionShape3D.new()
		add_child(collision_shape)
		if Engine.is_editor_hint():
			collision_shape.set_owner(get_tree().edited_scene_root)
		collision_shape.name = "CollisionShape3D"
		collision_shape.debug_color = Color.YELLOW
		collision_shape.debug_fill = false
		collision_shape.shape = BoxShape3D.new()
	if not has_node(SPAWN_AREAS_NAME):
		var spawn_areas := Node3D.new()
		add_child(spawn_areas)
		if Engine.is_editor_hint():
			spawn_areas.set_owner(get_tree().edited_scene_root)
		spawn_areas.name = SPAWN_AREAS_NAME
	_set_terrain_for_spawn_areas()


## Establishes the collision layers of a newly created zone.
func _init() -> void:
	set_collision_layer_value(Constants.DEFAULT_LAYER, false)
	set_collision_layer_value(Constants.MAP_LAYER, true)
	set_collision_mask_value(Constants.DEFAULT_LAYER, false)
	set_collision_mask_value(Constants.PLAYER_LAYER, true)


## Goes through all assigned SpawnAreas and sets their terrain zone.
func _set_terrain_for_spawn_areas() -> void:
	var areas_container: Node3D = get_node(SPAWN_AREAS_NAME)
	for area: Node in areas_container.get_children():
		if area is SpawnArea:
			area.set_terrain_zone(self)


## Randomly selects one of the map paths of this zone.
func select_random_map_path() -> String:
	var selected_index := randi_range(0, maps.size() - 1)
	return maps[selected_index]
