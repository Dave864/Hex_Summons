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

## The type of character this encounter spawn is.
@export var type := Type.MONSTER

## The speed the spawner moves at while idling.
var idle_speed := 4.0
## The speed the spawner moves at when reacting.
var reaction_speed := 8.0
## The distance the spawner can travel while in idle before despawining.
var idle_despawn_distance := 1.5
## The distance the spawner can travel while in reaction before despawning.
var reaction_despawn_distance := 2.0
## How close something must get before it is detected.
var alert_radius := 5.0:
	set = _set_alert_radius
## The terrain zone the spawner starts in.
var start_terrain_zone: TerrainZone = null
## The area the spawner starts in.
var spawn_area: SpawnArea = null
## The area the spawner wanders around in.
var roam_area: RoamArea = null

## The path to the map of the encounter.
var _encounter_map_path: String = ""
## The list of names of the enemies that will be in the encounter.
var _enemy_names_list: PackedStringArray = []
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
	_enemy_names_list = enemy_names


## Sets the area details.
func set_area_details(
	new_terrain_zone: TerrainZone,
	new_area: SpawnArea
) -> void:
	start_terrain_zone = new_terrain_zone
	spawn_area = new_area


## Emits the "despawned" signal.
func emit_despawned() -> void:
	emit_signal("despawned", get_instance_id())


## Sets the active state of the spawner.
func set_active(value: bool) -> void:
	_active = value


## Moves the spawner in the given direction.
func move_spawner(speed: float) -> void:
	var destination := nav_agent.get_next_path_position() - global_position
	velocity = destination.normalized() * speed
	move_and_slide()


## Updates the radius of the AlertRange collision detection.
func _set_alert_radius(new_radius: float) -> void:
	alert_radius = new_radius
	if not is_node_ready():
		return
	var alert_shape: CollisionShape3D = alert_range.get_node("CollisionShape3D")
	var alert_sphere := alert_shape.shape as SphereShape3D
	alert_sphere.radius = alert_radius


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
				_enemy_names_list
		)


## Updates the map to use when entering a new TerrainZone.
func _on_HitBox_area_entered(terrain_zone: Area3D) -> void:
	if not _active or not terrain_zone is TerrainZone:
		return
	terrain_zone = terrain_zone as TerrainZone
	_encounter_map_path = terrain_zone.select_random_map_path()
