class_name Character
extends Node3D
## Describes a character in an Encounter scene.
##
## Base class for players, mobs, and bosses. Contains a character's stats and map
## position details.


## Indicates that the character has been placed at start.
signal start_set()
## Indicates that the character is waiting.
signal is_waiting()
## Indicates that this character's turn has ended.
signal turn_ended()

## Describes character type.
enum Type {
	ENEMY, ## NPC opposed to the user
	PLAYER, ## Character controlled by the user
	SUMMON, ## Temporay character controlled by the user
	NONE ## No type assigned
}

@export var battle_portrait: Texture2D = null

## Flag that indicates whether the creature has been set to its starting location.
var _start_set: bool = false
var stats: StatModifiers

@onready var character_sprite: EncounterSprite = $EncounterSprite
@onready var character_label: CharacterLabel = $CharacterLabel
@onready var map_coordinate: MapCoordinate = $MapCoordinate
@onready var hit_box: Area3D = $HitBox
@onready var hm_move_path: HexMapMovementCurve = HexMapMovementCurve.new()


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_connect_stats_to_effects_tracker()


## Emits the is_waiting signal.
func emit_is_waiting() -> void:
	emit_signal("is_waiting")


## Emit the signal 'turn_ended'
func emit_turn_ended() -> void:
	emit_signal("turn_ended")


## Virtual function. Returns the character type.
func get_type() -> int:
	return Type.NONE


## Exposes the hitbox to action collisions.
func activate_hit_box() -> void:
	hit_box.monitoring = true


## Hides the hitbox from all collisions.
func deactivate_hit_box() -> void:
	hit_box.monitoring = false


## Sets the StatModifiers reference of the EffectsTracker.
func _connect_stats_to_effects_tracker() -> void:
	var effects_tracker: EffectsTracker = $EffectsTracker
	effects_tracker.set_character_stats(stats)


## Connects the relevant stat signals to the character label.
func _connect_to_character_label() -> void:
	ErrorUtil.connect_signal(
			stats,
			"health_changed",
			character_label,
			"_on_CharacterStatModifiers_health_changed"
	)
	character_label.set_max_health(stats.get_stat(Stat.Type.MAX_HEALTH))
	character_label.set_cur_health(stats.get_stat(Stat.Type.CUR_HEALTH))


## Virtual function. Updates emission points for all actions of the chracter.
func _update_emission_index(_index: int) -> void:
	pass


## Update the character's position index when passing over a MapTile.
func _on_Character_area_entered(map_tile: Area3D) -> void:
	_update_emission_index(map_tile.map_coordinate.get_tile_index())
	map_coordinate.set_tile_index(map_tile.map_coordinate.get_tile_index())
	map_coordinate.set_cube_coord(map_tile.map_coordinate.get_cube_coord())
	if !_start_set:
		_start_set = true
		emit_signal("start_set")
