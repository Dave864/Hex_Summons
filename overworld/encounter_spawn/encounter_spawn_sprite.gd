class_name EncounterSpawnSprite
extends Sprite3D
## A sprite that represents a character that will appear in an encounter. Used
## in EncounterSpawn.
##
## Uses a dither shader to simulate transparency. Is fully transparent when first
## initialized.


## Indicates when the sprite has fully transitioned from one "transparency" level
## to another.
signal transition_finished

## Specifies which transition the sprite is currently going through.
enum TransitionState {
	SPAWN,
	DESPAWN,
	NONE
}

## The default sprite used for the spawner.
const DEFAULT_SPRITE_PATH := (
	"res://character/enemy_characters/EnemyCharacter/EnemyBattleSprite.atlastex"
)
## The pixel size for the sprite.
const SPRITE_PIXEL_SIZE := 0.0625
## The max dither intensity (sprite is fully transparent).
const MAX_DITHER := 1.0
## The minimum dither intensity (sprite is fully opaque).
const MIN_DITHER := 0.0
## The time (seconds) it takes for the sprite to fully transition in "transparency".
const TRANSITION_TIME := 0.8

## The shader used for spawning and despawning.
var _dither_shader: Shader = preload(
		"res://overworld/encounter_spawn/billboard_dither_transparency.gdshader"
)
## The current transition state the sprite is in.
var _transition_state := TransitionState.NONE
## The time passed for the current transition.
var _current_time := 0.0


## Creates a new sprite using the given texture.
func _init(sprite_texture: Texture = null) -> void:
	name = "EncounterSpawnSprite"
	if sprite_texture == null:
		texture = load(DEFAULT_SPRITE_PATH)
	else:
		texture = sprite_texture
	pixel_size = SPRITE_PIXEL_SIZE
	billboard = BaseMaterial3D.BILLBOARD_ENABLED
	texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	_create_sprite_material()


## Readies the sprite for a spawn transition, going from fully transparent
## (maximum dithering intensity) to fully opaque (minimum dithering intensity).
func ready_spawn_transition() -> void:
	material_override.set_shader_parameter("dither_intensity", MAX_DITHER)
	_transition_state = TransitionState.SPAWN
	_current_time = 0.0


## Readies the sprite for a despawn transition, going from fully opaque (minimum
## dithering intensity) to fully transparent (maximum dithering intensity).
func ready_despawn_transition() -> void:
	material_override.set_shader_parameter("dither_intensity", MIN_DITHER)
	_transition_state = TransitionState.DESPAWN
	_current_time = 0.0


## Handles the processing of dither transitions.
func progress_transition(delta: float) -> void:
	if _transition_state == TransitionState.NONE:
		return
	_current_time += delta
	var intensity: float = clampf(
			_current_time / TRANSITION_TIME,
			MIN_DITHER,
			MAX_DITHER
	)
	if _transition_state == TransitionState.SPAWN:
		intensity = MAX_DITHER - intensity
	material_override.set_shader_parameter("dither_intensity", intensity)
	if _current_time >= TRANSITION_TIME:
		_transition_state = TransitionState.NONE
		emit_signal("transition_finished")


## Adds a shader to the sprite. Initially sets the dither intensity to full to
## have the sprite be transparent.
func _create_sprite_material() -> void:
	var shader_material := ShaderMaterial.new()
	material_override = shader_material
	shader_material.shader = _dither_shader
	shader_material.set_shader_parameter("sprite_texture", texture)
	shader_material.set_shader_parameter("dither_intensity", MAX_DITHER)
