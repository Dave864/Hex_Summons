class_name Action
extends Node
"""
Describes the details of an action.
"""


const SOURCE_RANGE: String = "SourceRange"
const DEAD_RANGE: String = "DeadRange"
const EFFECT_RANGE: String = "EffectRange"
const EFFECTS: String = "Effects"

export(NodePath) var hit_box_ref = null
# The percentage of a character's attack to use for potency calculations.
export(Resource) var potency = null
# Flag that denotes if the emission is fixed to the center of the area.
export(bool) var emit_from_center = true
# Flag that denotes if the effect should include the casting character tile.
export(bool) var effect_ignores_caster = true
# Flag that denotes if the possible source of the emmision is affected by tile heights.
export(bool) var source_ignore_heights = false
# Flag that denotes if the emission area is affected by tile heights.
export(bool) var effect_ignore_heights = false

# The path to the stats of the character that owns this action.
var source_stats: CharacterStats = null
# The area specifying the possible tiles for effect emmision.
var source_range: AreaRange = null
# The area that is ignored when determining the possible tiles for effect emmision.
var dead_range: AreaRange = null
# The area specifying the tiles affected by the effect.
var effect_range: AreaRange = null

# The hit box object.
var _hit_box: ActionHitBox = null
# The effects of this action
var _effects: Array setget , get_effects
# Whether the area range is cardinal or ring.
var _is_cardinal: bool = false setget , get_is_cardinal
# The index of the tile the effect is emitted from.
var _emission_map_index: int = -1 setget set_emission_map_index, get_emission_map_index
# The transform the effect is emitted from.
var _emission_transform: Transform = Transform.IDENTITY
# The direction the effect is emitted. Only updated if the action is cardinal.
var _emission_direction: int setget set_emission_direction, get_emission_direction

onready var ani_player: AnimationPlayer = $AnimationPlayer


# Returns the effects of this action.
func get_effects() -> Array:
	return _effects


# Returns if the area range is bound cardinally or not.
func get_is_cardinal() -> bool:
	return _is_cardinal


# Returns a set of targets this action effects.
func get_targets() -> Dictionary:
	var targets: Dictionary = {}
	for effect in _effects:
		for aspect in effect.get_aspects():
			targets[aspect.target] = true
	return targets


# Set the tile index the effect is emitted from.
func set_emission_map_index(index: int) -> void:
	_emission_map_index = index

# Return the index of the map tile the emission point is at.
func get_emission_map_index() -> int:
	return _emission_map_index


# Updates the origin of the emission transform.
func set_emission_pos(pos: Vector3) -> void:
	_emission_transform.origin = pos
	_hit_box.transform = _emission_transform


# Set the direction of the emission (0 - 5). Only updates the direction if
# the action is emitted from center.
func set_emission_direction(dir: int) -> void:
	if emit_from_center:
		_emission_direction = 0 if dir < 0 else 5 if dir > 5 else dir
		_emission_transform.basis = Basis(
				Vector3.UP,
				HexUtil.dir_rotation(_emission_direction)
		)
	else:
		_emission_direction = -1
		_emission_transform.basis = Basis.IDENTITY
	_hit_box.transform = _emission_transform


# Get the direction of the emission. Returns -1 if the action is not cardinal.
func get_emission_direction() -> int:
	return _emission_direction


# Get the hit box area of this action.
func get_hit_box() -> ActionHitBox:
	return _hit_box


# Resets the position of the emittor.
func reset_emittor_position() -> void:
	_emission_map_index = -1


# Executes the action.
func execute_action() -> void:
	_hit_box.transform = _emission_transform
	_hit_box.activate()
	print("Execute %s." % [name])
	ani_player.play("execute")
	yield(ani_player, "animation_finished")
	_hit_box.deactivate()


# Initialize the effects list of the action, checking that all effects are valid.
func initialize_effects() -> void:
	_effects = get_node("Effects").get_children()
	assert(
			len(_effects) > 0,
			"Error: Action %s does not have any effects" % [name]
	)
	for effect in _effects:
		assert(effect is Effect, "Error: Action %s effect %s is not an Effect")
		# Type checking for the node referenced at the path.
		effect.set_source_stats(source_stats)
		effect.set_action_potency(potency)


func _ready() -> void:
	_check_for_required_parameters()
	_hit_box = get_node(hit_box_ref)
	_is_cardinal = source_range is CardinalArea
	set_emission_direction(HexUtil.HexDirection.UPPER_LEFT)


# Checks that all required parameters are set.
func _check_for_required_parameters() -> void:
	assert(
			hit_box_ref != null,
			"Action {s} missing defined hit box reference.".format([name])
	)
	assert(
			potency != null,
			"ActionStats missing defined potency."
	)
	assert(
			potency is Potency,
			"ActionStats potency is not a Potency resource."
	)
	assert(
			has_node(EFFECTS),
			"Action {s} is missing the Effects node.".format([name])
	)
	_set_and_check_ranges()


# Gets the references to the range nodes, confirming if such nodes exist. 
func _set_and_check_ranges() -> void:
	source_range = get_node_or_null(SOURCE_RANGE)
	dead_range = get_node_or_null(DEAD_RANGE)
	effect_range = get_node_or_null(EFFECT_RANGE)
	assert(
			source_range != null,
			"Action {s} missing SourceRange node.".format([name])
	)
	assert(
			source_range is CardinalArea or source_range is RingArea,
			"Action {s} SourceRange is neither a CardinalArea " \
			+ "or RingArea.".format([name])
	)
	assert(
			dead_range != null,
			"Action {s} missing DeadRange node.".format([name])
	)
	assert(
			dead_range is CardinalArea or dead_range is RingArea,
			"Action {s} DeadRange is neither a CardinalArea " \
			+ "or RingArea.".format([name])
	)
	assert(
			effect_range != null,
			"Action {s} missing EffectRange node.".format([name])
	)
	assert(
			effect_range is AreaRange,
			"Action {s} EffectRange is not an AreaRange.".format([name])
	)
