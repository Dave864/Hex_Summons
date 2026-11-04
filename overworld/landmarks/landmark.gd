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
## Repositions spawn point so that it is on the transition radius.
@export_tool_button("Snap Spawn to Transition") var reposition_function := (
		_reposition_spawn_point
)
## Repositions spawn point so that it is on a map collision shape.
@export_tool_button("Relevel Spawn Point") var relevel_function := (
		_relevel_spawn_point
)

## The point where the player spawns when exiting the landmark's zone.
var _spawn_point: Marker3D = null
## The boundary area that causes the player to enter the landmark's zone.
var _transition_area: Area3D = null


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint():
		_create_missing_nodes()
	_spawn_point = $SpawnPoint
	_transition_area = $TransitionArea
	if not _transition_area.body_entered.is_connected(_on_body_entered):
		_transition_area.body_entered.connect(_on_body_entered)
	if Engine.is_editor_hint():
		_spawn_point.set_owner(get_tree().edited_scene_root)
		_transition_area.set_owner(get_tree().edited_scene_root)
		_transition_area.get_child(0).set_owner(get_tree().edited_scene_root)


## Gets the spawn point of this landmark in global coordinates.
func get_spawn_point() -> Vector3:
	return _spawn_point.global_position


## Creates spawn point, collision area, and placeholder mesh if they are not
## preset.
func _create_missing_nodes() -> void:
	if not has_node("SpawnPoint"):
		_spawn_point = Marker3D.new()
		_spawn_point.name = "SpawnPoint"
		add_child(_spawn_point)
	if not has_node("TransitionArea"):
		_transition_area = Area3D.new()
		var boundary_shape := CollisionShape3D.new()
		_transition_area.name = "TransitionArea"
		boundary_shape.name = "BoundaryShape"
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


## Moves the spawn point so that it is on the edge of the transition area.
func _reposition_spawn_point() -> void:
	var dir_to_spawn := (
			Vector3.BACK if _spawn_point.position.is_zero_approx()
			else _spawn_point.position.normalized()
	)
	_spawn_point.position = dir_to_spawn * transition_radius


## Reevaluates the position of the spawn point, placing it on a nav mesh if
## one is detected.
func _relevel_spawn_point() -> void:
	var raycast := RayCast3D.new()
	add_child(raycast)
	if Engine.is_editor_hint():
		raycast.set_owner(get_tree().edited_scene_root)
	raycast.set_collision_mask_value(Constants.MAP_LAYER, true)
	raycast.global_rotation = Vector3.ZERO
	raycast.target_position = Vector3(0.0, -10.0, 0.0)
	raycast.position = _spawn_point.position
	raycast.force_raycast_update()
	if raycast.is_colliding():
		_spawn_point.global_position = raycast.get_collision_point()
	raycast.queue_free.call_deferred()


## Triggers a scene switch to the connected zone.
func _on_body_entered(_player_collider: Node3D) -> void:
	pass
