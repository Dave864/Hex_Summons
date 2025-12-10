class_name PlayerCharacter
extends Character
## Handles behavior of a player character during an Encounter scene.
##
## Handles the setting of player data passed from PartyController. The intended use
## case is for this scene to be instanciated from a PackedScene, with specific
## player character data being supplied afterwards.


## The path to the default portrait for player characters.
const DEFAULT_PORTRAIT_PATH: String = (
		"res://character/player_characters/PlayerCharacter/" + \
		"PlayerBattlePortrait.atlastex"
)
## The path to the battle sprite for player characters.
const DEFAULT_BATTLE_PATH: String = (
		"res://character/player_characters/PlayerCharacter/" +\
		"PlayerBattleSprite.atlastex"
)
## Formatted string used to create the file path for the portrait of a player
## character.
const PORTRAIT_PATH_FORMAT: String = (
		"res://character/player_characters/{0}/" + \
		"BattlePortrait.atlastex"
)
## Formatted string used to create the file path for the battle sprite of a
## player character.
const BATTLE_PATH_FORMAT: String = (
		"res://character/player_characters/{0}/" + \
		"BattleSprite.atlastex"
)

## The player character's wisp pool.
var wisp_pool: PlayerWispPool = null
## The current player class; determines stat adjusters and abilities.
var _player_class: PlayerClass
## The techniques the character has access to.
var _techniques: Array
## The spells the character has access to.
var _spells: Array

## The default portrait for a player character.
@onready var _default_portait: Texture2D = preload(DEFAULT_PORTRAIT_PATH)
## The default battle sprite for a player character.
@onready var _default_battle: Texture2D = preload(DEFAULT_BATTLE_PATH)
## The node reference for the battle sprite.
@onready var _battle_sprite: EncounterSprite = $Sprite3D


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	battle_portrait = _default_portait
	_battle_sprite.texture = _default_battle


## Updates the character this node represents using data from the PartyController.
func update_player_details(player_details: Dictionary) -> void:
	name = player_details[PartyController.NAME]
	wisp_pool = player_details[PartyController.WISP_POOL]
	_update_sprites(name)
	_assign_class(player_details[PartyController.CLASS])


## Get the techniques associated with the character
func get_techniques() -> Array:
	return _techniques


## Get the spells associated with the character
func get_spells() -> Array:
	return _spells


## Returns the type of the character, PLAYER.
func get_type() -> int:
	return Type.PLAYER


## Assigns the player a class, creating a new class node.
func _assign_class(class_details: PlayerClassData) -> void:
	_player_class = PlayerClass.new(class_details)
	_player_class.name = "Class"
	add_child(_player_class)
	_techniques = _player_class.techniques
	_spells = _player_class.spells
	stats = _player_class.stats
	stats.entity_id = get_instance_id()
	_connect_to_character_label()
	_connect_stats_to_effects_tracker()
	_initialize_actions()


## Initializes the action effects.
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


## Updates the sprites to the ones for the given player.
func _update_sprites(player_name: String) -> void:
	var new_portrait: Texture2D = load(PORTRAIT_PATH_FORMAT.format([player_name]))
	var new_battle: Texture2D = load(BATTLE_PATH_FORMAT.format([player_name]))
	battle_portrait = new_portrait if new_portrait != null else _default_portait
	_battle_sprite.texture = new_battle if new_battle != null else _default_battle


## Virtual function. Updates emission points for all actions of the chracter.
func _update_emission_index(_index: int) -> void:
	for technique in _techniques:
		technique.set_emission_map_index(_index)
	for spell in _spells:
		spell.set_emission_map_index(_index)
