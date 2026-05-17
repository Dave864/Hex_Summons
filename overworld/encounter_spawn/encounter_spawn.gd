@abstract
class_name EncounterSpawn
extends CharacterBody3D
## Represents an enemy character that will trigger a random encounter when
## colliding with the OverworldAvatar.


## The default sprite used for the spawner.
const DEFAULT_SPRITE_PATH := (
	"res://character/enemy_characters/EnemyCharacter/EnemyBattleSprite.atlastex"
)
## The pixel size for the sprite.
const SPRITE_PIXEL_SIZE := 0.0625
## The radius of the spawner hitbox.
const HITBOX_RADIUS := 0.8

## The speed the spawner moves at.
var speed = 5.0

## The overworld avatar the spawner reacts to.
var _overworld_avatar: OverworldAvatar = null
## The path to the map of the encounter.
var _encounter_map_path: String = ""
## The list of paths to the enemies that will be in the encounter.
var _enemies_path_list : PackedStringArray = []


## Initializes the signal connections.
func _ready() -> void:
	$HitBox.connect("body_entered", Callable(self, "_on_HitBox_body_entered"))


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


## Moves the spawner based on the set behavior.
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	_behavior_pattern(delta)


## Removes the spawner from play.
func despawn() -> void:
	$HitBox.disconnect("body_entered", Callable(self, "_on_HitBox_body_entered"))
	queue_free()


## Creates the sprite for the node.
func _create_sprite() -> void:
	var sprite := Sprite3D.new()
	add_child(sprite)
	sprite.name = "Sprite3D"
	sprite.texture = load(DEFAULT_SPRITE_PATH)
	sprite.pixel_size = SPRITE_PIXEL_SIZE
	sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST


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


## The pattern the spawner follows. Uses the delta value for any behavior that
## depends on changes over time.
@abstract func _behavior_pattern(_delta: float) -> void


## Moves the spawner in the given direction.
func _move_spawner(input_dir: Vector3) -> void:
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.z)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()


## Triggers a switch to the Encounter scene when the OverworldAvatar is hit.
func _on_HitBox_body_entered(_avatar: OverworldAvatar) -> void:
	SceneController.change_scene_to_encounter(
			_encounter_map_path,
			_enemies_path_list
	)
