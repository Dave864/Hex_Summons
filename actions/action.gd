class_name Action
extends Node
## Describes the details of an action.


const EFFECTS: String = "Effects"

@export var hit_box_ref: NodePath = NodePath("")
@export var stats: ActionStats = null

## The path to the stats of the character that owns this action.
var source_stats: CharacterStats = null
## The effects of this action
var _effects: Array: get = get_effects
## Whether the area range is cardinal or ring.
var _is_cardinal: bool = false: get = get_is_cardinal
## The index of the tile the effect is emitted from.
var _emission_map_index: int = -1: get = get_emission_map_index, set = set_emission_map_index
## The transform the effect is emitted from.
var _emission_transform: Transform3D = Transform3D.IDENTITY
## The direction the effect is emitted. Only updated if the action is cardinal.
var _emission_direction: int: get = get_emission_direction, set = set_emission_direction

## The animation player for this node.
@onready var ani_player: AnimationPlayer = $AnimationPlayer
## The hit box object.
@onready var _hit_box: ActionHitBox = get_node(hit_box_ref)


func _ready() -> void:
	_check_for_required_parameters()
	_is_cardinal = stats.source_range is CardinalArea
	set_emission_direction(HexUtil.HexDirection.UPPER_LEFT)


## Returns the effects of this action.
func get_effects() -> Array:
	return _effects


## Returns if the area range is bound cardinally or not.
func get_is_cardinal() -> bool:
	return _is_cardinal


## Returns a set of targets this action effects.
func get_targets() -> Dictionary:
	var targets: Dictionary = {}
	for effect in _effects:
		for aspect in effect.get_aspects():
			targets[aspect.target] = true
	return targets


## Set the tile index the effect is emitted from.
func set_emission_map_index(index: int) -> void:
	_emission_map_index = index


## Return the index of the map tile the emission point is at.
func get_emission_map_index() -> int:
	return _emission_map_index


## Updates the origin of the emission transform.
func set_emission_pos(pos: Vector3) -> void:
	_emission_transform.origin = pos
	_hit_box.transform = _emission_transform


## Set the direction of the emission (0 - 5). Only updates the direction if
## the action is emitted from center.
func set_emission_direction(dir: int) -> void:
	if stats.emit_from_center:
		_emission_direction = 0 if dir < 0 else 5 if dir > 5 else dir
		_emission_transform.basis = Basis(
				Vector3.UP,
				HexUtil.dir_rotation(_emission_direction)
		)
	else:
		_emission_direction = -1
		_emission_transform.basis = Basis.IDENTITY
	_hit_box.transform = _emission_transform


## Get the direction of the emission. Returns -1 if the action is not cardinal.
func get_emission_direction() -> int:
	return _emission_direction


## Get the hit box area of this action.
func get_hit_box() -> ActionHitBox:
	return _hit_box


## Resets the position of the emittor.
func reset_emittor_position() -> void:
	_emission_map_index = -1


## Executes the action. Returns true when finished
func execute_action() -> bool:
	_hit_box.transform = _emission_transform
	_hit_box.activate()
	ani_player.play("execute")
	await ani_player.animation_finished
	_hit_box.deactivate()
	ani_player.play("RESET")
	return true


## Sets the caster id reference in the action hit box.
func initialize_caster_id(caster_id: int) -> void:
	_hit_box.caster_id = caster_id


## Initialize the effects list of the action, checking that all effects are valid.
func initialize_effects() -> void:
	_effects = get_node("Effects").get_children()
	assert(
			len(_effects) > 0,
			"Action %s does not have any effects" % [name]
	)
	for effect in _effects:
		assert(
				effect is Effect,
				"Action %s effect %s is not an Effect" % [name, effect.name]
		)
		# Type checking for the node referenced at the path.
		effect.set_source_stats(source_stats)
		effect.set_action_potency(stats.potency)


## Checks that all required parameters are set.
func _check_for_required_parameters() -> void:
	assert(
			hit_box_ref != null,
			"Action {0} missing defined hit box reference.".format([name])
	)
	assert(
			stats != null,
			"Action {0} missing stats.".format([name])
	)
	assert(
			has_node(EFFECTS),
			"Action {0} is missing the Effects node.".format([name])
	)
