class_name EncounterSpawnSprite
extends RotatingSprite3D
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

## The default name used when instancing this node.
const DEFAULT_NAME := "EncounterSpawnSprite"
## The default sprite used for the spawner.
const DEFAULT_SPRITE_PATH := (
	"res://art/icon.png"
)
## The path format to a character's sprite sheet.
const CHAR_SPRITE_FRAMES_PATH := (
		"res://character/enemy_characters/{0}/sprite_frames.tres"
)
## The path format to a character's shader.
const CHAR_SHADER_PATH := (
		"res://character/enemy_characters/{0}/character_sprite_xray.tres"
)
## The pixel size for the sprite.
const SPRITE_PIXEL_SIZE := 0.0625
## The max dither intensity (sprite is fully transparent).
const MAX_DITHER := 1.0
## The minimum dither intensity (sprite is fully opaque).
const MIN_DITHER := 0.0
## The time (seconds) it takes for the sprite to fully transition in "transparency".
const TRANSITION_TIME := 0.8

## The current transition state the sprite is in.
var _transition_state := TransitionState.NONE
## The time passed for the current transition.
var _current_time := 0.0


## Sets the sprite frames and shader texture to match the specified character.
func set_texture_to_character(char_name: String) -> void:
	var sprite_frames_path := CHAR_SPRITE_FRAMES_PATH.format([char_name])
	sprite_frames = load(sprite_frames_path)
	var shader_path := CHAR_SHADER_PATH.format([char_name])
	var shader: ShaderMaterial = load(shader_path)
	var shader_texture: Texture2D = shader.get_shader_parameter("sprite_texture")
	shader = material_override
	shader.set_shader_parameter("sprite_texture", shader_texture)


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
