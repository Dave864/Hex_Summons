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
		"BattlePortrait.atlastex"
)
## Formatted string used to create the file path for the portrait of a player
## character.
const PORTRAIT_PATH_FORMAT: String = (
		"res://character/player_characters/{0}/" + \
		"BattlePortrait.atlastex"
)

## The player character's wisp pool.
var wisp_pool: PlayerWispPool = null
## The current player class; determines stat adjusters and abilities.
var _player_class: PlayerClass
## The techniques the character has access to.
var _techniques: Array[Action]
## The spells the character has access to.
var _spells: Array[Action]

## The default portrait for a player character.
@onready var _default_portait: Texture2D = preload(DEFAULT_PORTRAIT_PATH)


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	battle_portrait = _default_portait


## Updates the character this node represents using data from the PartyController.
func update_player_details(player_details: PartyController.PlayerDetails) -> void:
	name = player_details.name
	wisp_pool = player_details.wisp_pool
	_update_sprites(name)
	_assign_class(player_details.class_data)


## Get the techniques associated with the character
func get_techniques() -> Array[Action]:
	return _techniques


## Get the spells associated with the character
func get_spells() -> Array[Action]:
	return _spells


## Returns the type of the character, PLAYER.
func get_type() -> Type:
	return Type.PLAYER


## Assigns the player a class, creating a new class node.
func _assign_class(class_details: PlayerClassData) -> void:
	_player_class = PlayerClass.new(class_details)
	_player_class.name = "Class"
	add_child(_player_class)
	_techniques = _player_class.techniques
	_spells = _player_class.spells
	stats = _player_class.stats
	stats.character_id = get_instance_id()
	stats.character_type = Character.Type.PLAYER
	_connect_to_character_label()
	_connect_stats_to_effects_tracker()
	_initialize_actions()


## Initializes the action effects.
func _initialize_actions() -> void:
	for t: Action in _techniques:
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
	for s: Action in _spells:
		assert(
				s.has_node("WispCost"),
				"Player class {0} spell {1} is missing a WispCost " \
				+ "node.".format([_player_class.name, s.name])
		)
		s.get_node("WispCost").wisp_pool = wisp_pool
		s.source_stats = stats


## Updates the sprites to the ones for the given player.
func _update_sprites(player_name: String) -> void:
	var new_portrait: Texture2D = load(PORTRAIT_PATH_FORMAT.format([player_name]))
	battle_portrait = new_portrait if new_portrait != null else _default_portait
