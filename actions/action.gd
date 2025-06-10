class_name Action
extends Node
"""
Describes the details of an action.
"""


const SOURCE_RANGE: String = "SourceRange"
const DEAD_RANGE: String = "DeadRange"
const EFFECT_RANGE: String = "EffectRange"
const EFFECTS: String = "Effects"

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

# The effects of this action
var _effects: Array setget , get_effects
# Whether the area range is cardinal or ring.
var _is_cardinal: bool = false setget , get_is_cardinal
# The index of the tile the effect is emitted from.
var _emission_map_index: int = -1 setget set_emission_map_index, get_emission_map_index
# The direction the effect is emitted. Only updated if the action is cardinal.
var _emission_direction: int setget set_emission_direction, get_emission_direction


# Returns the effects of this action.
func get_effects() -> Array:
	return _effects


# Returns if the area range is bound cardinally or not.
func get_is_cardinal() -> bool:
	return _is_cardinal


# Set the tile index the effect is emitted from.
func set_emission_map_index(index: int) -> void:
	_emission_map_index = index

# Return the index of the map tile the emission point is at.
func get_emission_map_index() -> int:
	return _emission_map_index


# Set the direction of the emission (0 - 5). Only updates the direction if the action
# is cardinal.
func set_emission_direction(dir: int) -> void:
	if _is_cardinal:
		_emission_direction = 0 if dir < 0 else 5 if dir > 5 else dir
	else:
		_emission_direction = -1


# Get the direction of the emission. Returns -1 if the action is not cardinal.
func get_emission_direction() -> int:
	return _emission_direction


# Resets the position of the emittor.
func reset_emittor_position() -> void:
	_emission_map_index = -1


func _ready() -> void:
	_check_for_required_parameters()
	_initialize_effects()
	_is_cardinal = source_range is CardinalArea
	set_emission_direction(HexUtil.HexDirection.UPPER_LEFT)


# Checks that all required parameters are set.
func _check_for_required_parameters() -> void:
	assert(
			potency != null,
			"Error: ActionStats missing defined potency."
	)
	assert(
			potency is Potency,
			"Error: ActionStats potency is not a Potency resource."
	)
	assert(
			has_node(EFFECTS),
			"Error: Action %s is missing the Effects node." % [name]
	)
	_set_and_check_ranges()


# Initialize the effects list of the action, checking that all effects are valid.
func _initialize_effects() -> void:
	_effects = get_node("Effects").get_children()
#	assert(
#			len(_effects) > 0,
#			"Error: Action %s does not have any effects" % [name]
#	)
	for effect in _effects:
		assert(effect is Effect, "Error: Action %s effect %s is not an Effect")
		# Type checking for the node referenced at the path.
		effect.set_source_stats(source_stats)
		effect.set_action_potency(potency)


# Gets the references to the range nodes, confirming if such nodes exist. 
func _set_and_check_ranges() -> void:
	source_range = get_node_or_null(SOURCE_RANGE)
	dead_range = get_node_or_null(DEAD_RANGE)
	effect_range = get_node_or_null(EFFECT_RANGE)
	assert(
			source_range != null,
			"Error: Action %s missing SourceArea node." % [name]
	)
	assert(
			source_range is CardinalArea or source_range is RingArea,
			"Error: Action %s SourceRange is neither a CardinalArea " \
			+ "or RingArea." % [name]
	)
	if dead_range != null:
		assert(
				dead_range is CardinalArea or dead_range is RingArea,
				"Error: Action %s DeadRange is neither a CardinalArea " \
				+ "or RingArea." % [name]
		)
	assert(
			effect_range != null,
			"Error: Action %s missing EffectRange node." % [name]
	)
	assert(
			effect_range is AreaRange,
			"Error: Action %s EffectRange is not an AreaRange." % [name]
	)
