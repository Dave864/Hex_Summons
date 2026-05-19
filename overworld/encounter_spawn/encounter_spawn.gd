@abstract
class_name EncounterSpawn
extends CharacterBody3D
## Represents an enemy character that will trigger a random encounter when
## colliding with the OverworldAvatar.


## The radius of the spawner hitbox.
const HITBOX_RADIUS := 0.8
## The maximum value for dither intensity.
const MAX_DITHER_INTENSITY := 1.0

## The speed the spawner moves at.
var speed = 8.0

## The overworld avatar the spawner reacts to.
var _overworld_avatar: OverworldAvatar = null
## The path to the map of the encounter.
var _encounter_map_path: String = ""
## The list of paths to the enemies that will be in the encounter.
var _enemies_path_list : PackedStringArray = []
## The position of the spawner in the last frame.
var _prior_position := Vector3.ZERO
## Flag that indicates if the spawner is active.
var _active: bool = false
## The navigation agent for this spawner.
var _nav_agent: NavigationAgent3D = null


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
	_nav_agent = NavigationAgent3D.new()
	add_child(_nav_agent)
	_nav_agent.name = "NavAgent"


## Moves the spawner based on the set behavior.
func _physics_process(delta: float) -> void:
	_behavior_pattern(delta)


## Causes the sprite to appear.
func spawn() -> bool:
	var sprite: EncounterSpawnSprite = $EncounterSpawnSprite
	_prior_position = position
	sprite.spawn_transition()
	await sprite.transition_finished
	_active = true
	return true


## Removes the spawner from play.
func despawn() -> void:
	#$HitBox.disconnect("body_entered", Callable(self, "_on_HitBox_body_entered"))
	_active = false
	var sprite: EncounterSpawnSprite = $EncounterSpawnSprite
	sprite.despawn_transition()
	await sprite.transition_finished
	queue_free()


## Creates the sprite for the node.
func _create_sprite() -> void:
	var sprite := EncounterSpawnSprite.new()
	add_child(sprite)


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


## Creates the hit box used to detect when the spawner has hit the player.
func _create_hitbox() -> void:
	var hitbox := Area3D.new()
	add_child(hitbox)
	hitbox.name = "HitBox"
	hitbox.set_collision_layer_value(Constants.DEFAULT_LAYER, false)
	hitbox.set_collision_layer_value(Constants.ENEMY_LAYER, true)
	hitbox.set_collision_mask_value(Constants.DEFAULT_LAYER, false)
	hitbox.set_collision_mask_value(Constants.PLAYER_LAYER, true)
	var hitbox_shape := CollisionShape3D.new()
	hitbox.add_child(hitbox_shape)
	hitbox_shape.name = "CollisionShape3D"
	var shape_dimensions := CylinderShape3D.new()
	shape_dimensions.radius = HITBOX_RADIUS
	hitbox_shape.shape = shape_dimensions
	hitbox.connect("body_entered", Callable(self, "_on_HitBox_body_entered"))


## The pattern the spawner follows. Uses the delta value for any behavior that
## depends on changes over time.
@abstract func _behavior_pattern(_delta: float) -> void


## Moves the spawner in the given direction.
func _move_spawner() -> void:
	var destination := _nav_agent.get_next_path_position() - global_position
	velocity = destination.normalized() * speed
	move_and_slide()


## Triggers a switch to the Encounter scene when the OverworldAvatar is hit.
func _on_HitBox_body_entered(_avatar: OverworldAvatar) -> void:
	SceneController.change_scene_to_encounter(
			_encounter_map_path,
			_enemies_path_list
	)
