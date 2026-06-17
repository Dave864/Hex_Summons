@abstract
class_name EncounterSpawn
extends CharacterBody3D
## Represents an enemy character that will trigger a random encounter when
## colliding with the OverworldAvatar.


## Indicates that this node is going to be despawned. Passes along the instance
## id of this node.
signal despawned(id)

## The radius of the spawner hitbox.
const HITBOX_RADIUS := 0.8
## The amount to offset the y positions of the child nodes by so that the anchor
## of this node is at the bottom.
const ANCHOR_OFFSET := 1.0
## The name of the navigation agent.
const NAV_AGENT_NAME := "NavAgent"

## The speed the spawner moves at.
var speed = 8.0
## The sprite used.
var sprite: EncounterSpawnSprite:
	get():
		return get_node(EncounterSpawnSprite.DEFAULT_NAME)
## The navigation agent for this spawner.
var nav_agent: NavigationAgent3D:
	get():
		return get_node(NAV_AGENT_NAME)

## The overworld avatar the spawner reacts to.
var _overworld_avatar: OverworldAvatar = null
## The path to the map of the encounter.
var _encounter_map_path: String = ""
## The list of paths to the enemies that will be in the encounter.
var _enemies_path_list : PackedStringArray = []
## Flag that indicates if the spawner is active.
var _active: bool = false


## Initializes the node.
func _init(
	overworld_avatar: OverworldAvatar,
	encounter_map_path: String,
	enemies_path_list: PackedStringArray
) -> void:
	_overworld_avatar = overworld_avatar
	_encounter_map_path = encounter_map_path
	_enemies_path_list = enemies_path_list
	_create_sprite()
	_create_physics_shape()
	_create_hitbox()
	var new_nav_agent := NavigationAgent3D.new()
	add_child(new_nav_agent)
	new_nav_agent.name = NAV_AGENT_NAME


## Emits the "despawned" signal.
func emit_despawned() -> void:
	emit_signal("despawned", get_instance_id())


## Sets the active state of the spawner.
func set_active(value: bool) -> void:
	_active = value


## Creates the sprite for the node.
func _create_sprite() -> void:
	add_child(EncounterSpawnSprite.new())
	sprite.position.y = ANCHOR_OFFSET


## Creates the collision shape used for interacting with the world.
func _create_physics_shape() -> void:
	var physics_shape := CollisionShape3D.new()
	add_child(physics_shape)
	physics_shape.name = "CollisionShape3D"
	set_collision_layer_value(Constants.DEFAULT_LAYER, false)
	set_collision_layer_value(Constants.ENEMY_LAYER, true)
	set_collision_mask_value(Constants.DEFAULT_LAYER, false)
	set_collision_mask_value(Constants.MAP_LAYER, true)
	physics_shape.shape = CapsuleShape3D.new()
	physics_shape.position.y = ANCHOR_OFFSET


## Creates the hit box used to detect when the spawner has hit the player.
func _create_hitbox() -> void:
	var hitbox := Area3D.new()
	add_child(hitbox)
	hitbox.name = "HitBox"
	hitbox.set_collision_layer_value(Constants.DEFAULT_LAYER, false)
	hitbox.set_collision_layer_value(Constants.ENEMY_LAYER, true)
	hitbox.set_collision_mask_value(Constants.DEFAULT_LAYER, false)
	hitbox.set_collision_mask_value(Constants.PLAYER_LAYER, true)
	hitbox.position.y = ANCHOR_OFFSET
	var hitbox_shape := CollisionShape3D.new()
	hitbox.add_child(hitbox_shape)
	hitbox_shape.name = "CollisionShape3D"
	var shape_dimensions := CylinderShape3D.new()
	shape_dimensions.radius = HITBOX_RADIUS
	hitbox_shape.shape = shape_dimensions
	hitbox.connect("body_entered", Callable(self, "_on_HitBox_body_entered"))
	hitbox.connect("area_entered", Callable(self, "_on_HitBox_area_entered"))


## Moves the spawner in the given direction.
func _move_spawner() -> void:
	var destination := nav_agent.get_next_path_position() - global_position
	velocity = destination.normalized() * speed
	move_and_slide()


## Triggers a switch to the Encounter scene when the OverworldAvatar is hit.
func _on_HitBox_body_entered(_avatar: OverworldAvatar) -> void:
	if not _active:
		return
	SceneController.change_scene_to_encounter(
			_encounter_map_path,
			_enemies_path_list
	)


## Updates the map to use when entering a new TerrainZone.
func _on_HitBox_area_entered(terrain_zone: Area3D) -> void:
	if not _active or not terrain_zone is TerrainZone:
		return
	terrain_zone = terrain_zone as TerrainZone
	_encounter_map_path = terrain_zone.select_random_map_path()
