class_name PlayerCharacter
extends Character
"""
Handles actions specific to player characters.
"""


# The current player class; determines stat adjusters and abilities.
var _player_class: PlayerClass
# References to the various attacks and spells the character has access to.
var _techniques: Array
var _spells: Array


@onready var wisp_pool: PlayerWispPool = $PlayerWispPool
@onready var _default_portait: Texture2D = preload(
		"res://character/player_characters/PlayerCharacter/" + \
		"PlayerBattlePortrait.atlastex"
)


# Assigns the player a class, updating the relevant details.
func assign_class(new_class: PlayerClass) -> void:
	_player_class = new_class
	_techniques = _player_class.techniques
	_spells = _player_class.spells
	stats = _player_class.stats
	stats.character_id = get_instance_id()
	_connect_to_character_label()
	_connect_stats_to_effects_tracker()
	_initialize_actions()


# Get the techniques associated with the character
func get_techniques() -> Array:
	return _techniques


# Get the spells associated with the character
func get_spells() -> Array:
	return _spells


# Returns the type of the character, PLAYER.
func get_type() -> int:
	return Type.PLAYER


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	wisp_pool.player_name = name
	battle_portrait = (
		_default_portait if battle_portrait == null
		else battle_portrait
	)
	assign_class($Class)


# Initializes the action effects.
func _initialize_actions() -> void:
	for t in _techniques:
		assert(
				t.has_node("Cooldown"),
				"Player class {0} technique {1} is missing a Cooldown " \
				+ "node.".format([_player_class.name, t.name])
		)
		ErrorUtil.connect_signal(
				self,
				"turn_ended",
				t.get_node("Cooldown"),
				"_on_Character_turn_ended"
		)
		t.source_stats = stats
		t.initialize_effects()
		t.initialize_caster_id(get_instance_id())
	for s in _spells:
		assert(
				s.has_node("WispCost"),
				"Player class {0} spell {1} is missing a WispCost " \
				+ "node.".format([_player_class.name, s.name])
		)
		s.get_node("WispCost").wisp_pool = wisp_pool
		s.source_stats = stats
		s.initialize_effects()
		s.initialize_caster_id(get_instance_id())


# Virtual function. Updates emission points for all actions of the chracter.
func _update_emission_index(_index: int) -> void:
	for technique in _techniques:
		technique.set_emission_map_index(_index)
	for spell in _spells:
		spell.set_emission_map_index(_index)
