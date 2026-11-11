@tool
class_name Landmark
extends MeshInstance3D
## An overworld mesh with collision that represents a point of interest.
##
## Initializes a mesh and collision area when added to a scene. The collision
## indicates the transition area, the boundary where the player moves to the
## landmaerk's connected zone. Allows for the defining of spawn
## location when the player enters the overworld from said area.


## The radius of the transition area.
@export_range(0.01, 50.0, 0.01) var transition_radius := 2.0:
	set = _update_transition_area
@export_range(0.01, 20.0, 0.01) var spawn_distance := 2.1:
	set = _update_spawn_distance
## Repositions spawn point so that it is on the transition radius.
@export_tool_button("Snap Spawn to Transition") var reposition_function := (
		_reposition_spawn_point
)

## Indicates how far away the spawner will be.
var _spawn_marker: AreaGizmoCircle = null
## The boundary area that causes the player to enter the landmark's zone.
var _transition_area: Area3D = null


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint():
		_create_missing_nodes()
	_spawn_marker = $SpawnMarker
	_transition_area = $TransitionArea
	if not _transition_area.body_entered.is_connected(_on_body_entered):
		_transition_area.body_entered.connect(_on_body_entered)
	if Engine.is_editor_hint():
		_update_transition_area(transition_radius)
		_spawn_marker.set_owner(get_tree().edited_scene_root)
		_transition_area.set_owner(get_tree().edited_scene_root)
		_transition_area.get_child(0).set_owner(get_tree().edited_scene_root)


## Gets the spawn point in global coordinates.
func get_spawn_point() -> Vector3:
	var spawn_point := Vector3(
			global_position.x,
			global_position.y + 0.5,
			global_position.z
	)
	# Rotate transition direction so that spawn point aligns with the orientation
	# of the landmark in the overworld.
	spawn_point += Vector3(
		SceneController.landmark_transition_direction.x,
		0.0,
		SceneController.landmark_transition_direction.y
	).rotated(Vector3.UP, global_rotation.y) * spawn_distance
	return _relevel_spawn_point(spawn_point)


## Creates spawn point, collision area, and placeholder mesh if they are not
## preset.
func _create_missing_nodes() -> void:
	if not has_node("SpawnMarker"):
		_spawn_marker = AreaGizmoCircle.new()
		_spawn_marker.name = "SpawnMarker"
		add_child(_spawn_marker)
		_spawn_marker.radius = spawn_distance
		_spawn_marker.color = Color.LAWN_GREEN
	if not has_node("TransitionArea"):
		_transition_area = Area3D.new()
		var boundary_shape := CollisionShape3D.new()
		_transition_area.name = "TransitionArea"
		boundary_shape.name = "BoundaryShape"
		boundary_shape.debug_color = Color.DARK_BLUE
		add_child(_transition_area)
		_transition_area.add_child(boundary_shape)
		_transition_area.set_collision_layer_value(
				Constants.DEFAULT_LAYER,
				false
		)
		_transition_area.set_collision_layer_value(Constants.MAP_LAYER, true)
		_transition_area.set_collision_mask_value(
				Constants.DEFAULT_LAYER,
				false
		)
		_transition_area.set_collision_mask_value(Constants.PLAYER_LAYER, true)
		var sphere := SphereShape3D.new()
		sphere.radius = transition_radius
		boundary_shape.shape = sphere
	if mesh == null:
		var placeholder_mesh := BoxMesh.new()
		placeholder_mesh.size = Vector3.ONE
		mesh = placeholder_mesh


## Updates the collision shape to match the new radius.
func _update_transition_area(new_radius: float) -> void:
	if not is_node_ready():
		return
	var owner_id := _transition_area.get_shape_owners()[0]
	var boundary_sphere := _transition_area.shape_owner_get_shape(
			owner_id,
			0
	) as SphereShape3D
	boundary_sphere.radius = new_radius
	transition_radius = new_radius


## Updates the spawn distance from the center of the landmark. Updates the spawn
## marker to indicate the distance.
func _update_spawn_distance(new_distance: float) -> void:
	spawn_distance = new_distance
	if _spawn_marker != null:
		_spawn_marker.radius = spawn_distance


## Moves the spawn marker so that it is on the edge of the transition area.
func _reposition_spawn_point() -> void:
	_spawn_marker.radius = transition_radius


## Reevaluates the position of a spawn point, return the point where it rests on
## a nav mesh if one is detected.
func _relevel_spawn_point(spawn_point: Vector3) -> Vector3:
	var raycast := RayCast3D.new()
	add_child(raycast)
	if Engine.is_editor_hint():
		raycast.set_owner(get_tree().edited_scene_root)
	raycast.set_collision_mask_value(Constants.MAP_LAYER, true)
	raycast.global_rotation = Vector3.ZERO
	raycast.target_position = Vector3(0.0, -10.0, 0.0)
	raycast.global_position = spawn_point
	raycast.force_raycast_update()
	var new_point := (
			spawn_point if not raycast.is_colliding()
			else raycast.get_collision_point()
	)
	raycast.queue_free.call_deferred()
	return new_point


## Triggers a scene switch to the connected zone.
func _on_body_entered(player_collider: Node3D) -> void:
	var entry_direction := player_collider.global_position.direction_to(
			global_position
	)
	# Rotate to match orientation of landmark so that is aligns with the
	# orientation of the connected zone.
	SceneController.landmark_transition_direction = Vector2(
			entry_direction.x,
			entry_direction.z
	).normalized().rotated(global_rotation.y)
	SceneController.change_scene_to_connected_zone(name)
