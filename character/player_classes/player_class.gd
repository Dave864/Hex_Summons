@tool
class_name PlayerClass
extends Node
## Describes a class a player character can be. A player class defines the current
## statistics the player will have, along with some techniques and spells that the
## player will have access to.

## Name of the node that holds the character stats.
const STATS: String = "Stats"
## Name of the node that contains the technique actions.
const TECHNIQUES: String = "Techniques"
## Name of the node that contains the spell actions.
const SPELLS: String = "Spells"
## Path format to access the scene of an action.
const ACTION_PATH_FORMAT: String = "res://actions/action_nodes/{0}/{0}.tscn"

## The modified stats of the class that are used for a player character.
var stats: CharacterStatModifiers
## The techniques inherent to this class.
var techniques: Array[Action]
## The spells inherent to this class.
var spells: Array[Action]

## Reference to the scene tree root.
@onready var _root_node: Node = get_tree().edited_scene_root


## Called when the node enters the scene tree for the first time.
func _ready():
	# Initialize the child nodes if not present in the scene
	if Engine.is_editor_hint() and get_child_count() == 0:
		_create_child_nodes()
		$Stats.set_owner(_root_node)
		$Techniques.set_owner(_root_node)
		$Spells.set_owner(_root_node)
	else:
		stats = get_node(STATS)
	for technique: Action in get_node(TECHNIQUES).get_children():
		techniques.append(technique)
	for spell: Action in get_node(SPELLS).get_children():
		spells.append(spell)


## Called when creating a new instance of this object.
func _init(class_data: PlayerClassData = null) -> void:
	if class_data == null:
		return
	name = class_data.name
	_create_child_nodes()
	stats.base_stat_values = class_data.stats
	for technique in class_data.techniques:
		_create_technique_node(technique)
	for spell in class_data.spells:
		_create_spell_node(spell)


## Creates the nodes for spells, techniques, and character stats.
func _create_child_nodes() -> void:
	stats = CharacterStatModifiers.new()
	var t_node: Node = Node.new()
	var s_node: Node = Node.new()
	stats.name = STATS
	t_node.name = TECHNIQUES
	s_node.name = SPELLS
	add_child(stats)
	add_child(t_node)
	add_child(s_node)


## Creates a node for the given technique details.
func _create_technique_node(tech_stats: TechniqueStats) -> void:
	var tech_name: String = tech_stats.action_stats.name
	var action_path: String = ACTION_PATH_FORMAT.format([tech_name])
	var technique_node: Action = load(action_path).instantiate()
	var cooldown_node: Cooldown = Cooldown.new(tech_stats.cooldown)
	technique_node.add_child(cooldown_node)
	$Techniques.add_child(technique_node)


## Creates a node for the given spell details.
func _create_spell_node(spell_stats: SpellStats) -> void:
	var spell_name: String = spell_stats.action_stats.name
	var action_path: String = ACTION_PATH_FORMAT.format([spell_name])
	var spell_node: Action = load(action_path).instantiate()
	var wisp_cost_node: WispCost = WispCost.new(
			spell_stats.get_requirements(),
			spell_stats.get_costs()
	)
	spell_node.add_child(wisp_cost_node)
	$Spells.add_child(spell_node)
