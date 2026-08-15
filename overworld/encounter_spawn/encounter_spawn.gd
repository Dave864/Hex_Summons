class_name EncounterSpawn
extends CharacterBody3D
## Represents an enemy character that will trigger a random encounter when
## colliding with the OverworldAvatar.


## Indicates that this node is going to be despawned. Passes along the instance
## id of this node.
signal despawned(id)

## The different character options.
enum Type {
	MONSTER,
	PREDATOR,
	PREY,
}

## The format for the path to the spawn parameters of a character.
const CHAR_SPAWN_PARAMETERS_PATH := (
		Constants.ENEMY_CHAR_FOLDER + "spawn_parameters.tres"
)

## The type of character this encounter spawn is.
@export var type := Type.MONSTER

## The behavior parameters for this spawner.
var spawn_params: SpawnParameters = null
## The terrain zone the spawner starts in.
var start_terrain_zone: TerrainZone = null
## The area the spawner wanders around in.
var roam_area: RoamArea = null

## The path to the map of the encounter.
var _encounter_map_path: String = ""
## The list of names of the enemies that will be in the encounter.
var _enemy_names: PackedStringArray = []
## Flag that indicates if the spawner is active.
var _active: bool = false

## Timer for various state events.
@onready var timer: Timer = $Timer
## The collision area for detecting if something is approaching.
@onready var alert_range: Area3D = $AlertRange
## The sprite used.
@onready var sprite: EncounterSpawnSprite = $EncounterSpawnSprite
## The navigation agent for this spawner.
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D


## Sets the initial orientation to a random value.
func _ready() -> void:
	sprite.face_random_direction()
	# TODO: Set sprite to be the dominant enemy. Currently just sets
	# it to the first one.
	sprite.set_texture_to_character(_enemy_names[0])
	sprite.play_idle()


## Removes the RoamArea from the scene tree and queues it for deletion.
func _exit_tree() -> void:
	if roam_area != null:
		roam_area.queue_free()


## Sets the details used for populating the encounter.
func set_encounter_details(
	map_path: String,
	enemy_names: PackedStringArray
) -> void:
	_encounter_map_path = map_path
	_enemy_names = enemy_names
	# TODO: Set spawn to be dominant enemy. Current just uses the first enemy as
	# the basis for the behavior.
	spawn_params = load(CHAR_SPAWN_PARAMETERS_PATH.format([_enemy_names[0]]))


## Sets the terrain zone details.
func set_start_terrain_zone(
	new_terrain_zone: TerrainZone,
) -> void:
	start_terrain_zone = new_terrain_zone


## Sets the target position for the navigation agent.
func set_nav_target(destination: Vector3) -> void:
	nav_agent.target_position = destination


## Sets the navigation agent target position to a random travel point relative
## to EncounterSpawn's current position. Can specify a range the point must be
## in. If the ranges contradict each other, or no point could be found in
## the given range, any random point is returned.
func set_nav_to_travel_point(
	min_dist: float = -1.0,
	max_dist: float = -1.0
) -> void:
	var point: Vector3
	if min_dist >= max_dist or (min_dist < 0.0 and max_dist < 0.0):
		point = start_terrain_zone.travel_point_zones.get_a_global_point()
	elif min_dist > 0.0 and max_dist < 0.0:
		point = start_terrain_zone.travel_point_zones.get_a_global_point_beyond(
				min_dist,
				global_position
		)
	elif max_dist > 0.0 and min_dist < 0.0:
		point = start_terrain_zone.travel_point_zones.get_a_global_point_in(
				max_dist,
				global_position
		)
	else:
		point = start_terrain_zone.travel_point_zones.get_a_global_point_within(
				min_dist,
				max_dist,
				global_position
		)
	if not point.is_finite():
		point = global_position
	nav_agent.target_position = point


## Emits the "despawned" signal.
func emit_despawned() -> void:
	_active = false
	emit_signal("despawned", get_instance_id())


## Sets the active state of the spawner.
func set_active(value: bool) -> void:
	_active = value


## Checks if the spawner is active.
func is_active() -> bool:
	return _active


## Moves the spawner towards the navigation target.
func move_to_navigation(speed: float) -> void:
	var destination := nav_agent.get_next_path_position() - global_position
	var dir3D := destination.normalized()
	velocity = dir3D * speed
	sprite.facing_direction = Vector2(dir3D.x, dir3D.z).normalized()
	move_and_slide()


## Moves the spawner in the specified direction, accounting for gravity.
func move_in_direction(speed: float, xz_dir: Vector2, delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	velocity.x = xz_dir.x * speed
	velocity.z = xz_dir.y * speed
	sprite.facing_direction = xz_dir
	move_and_slide()


## Updates the radius of the AlertRange collision detection.
func _set_alert_radius(new_radius: float) -> void:
	if not is_node_ready():
		return
	var alert_shape: CollisionShape3D = alert_range.get_node("CollisionShape3D")
	var alert_sphere := alert_shape.shape as SphereShape3D
	alert_sphere.radius = new_radius


## Triggers a switch to the Encounter scene when the OverworldAvatar is hit.
func _on_HitBox_body_entered(body: Node3D) -> void:
	if not _active:
		return
	if body is EncounterSpawn:
		if body.type != type:
			emit_despawned()
	if body is OverworldAvatar:
		SceneController.change_scene_to_encounter(
				_encounter_map_path,
				_enemy_names
		)


## Updates the map to use when entering a new TerrainZone.
func _on_HitBox_area_entered(terrain_zone: Area3D) -> void:
	if not _active or not terrain_zone is TerrainZone:
		return
	terrain_zone = terrain_zone as TerrainZone
	_encounter_map_path = terrain_zone.select_random_map_path()
