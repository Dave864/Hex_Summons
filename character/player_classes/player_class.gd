tool
extends Node
class_name PlayerClass
"""
Describes a class a player character can be. A player class defines the current
statistics the player will have, along with some techniques and spells that the
player will have access to.
"""

const STATS = "Stats"
const TECHNIQUES = "Techniques"
const SPELLS = "Spells"

var stats: CharacterStats
var techniques: Array
var spells: Array

# Reference to the scene tree root.
onready var _root_node: Node = get_tree().edited_scene_root


# Called when the node enters the scene tree for the first time.
func _ready():
	# Initialize the child nodes if not present in the scene
	if Engine.is_editor_hint() and get_child_count() == 0:
		stats = CharacterStats.new()
		var t_node: Node = Node.new()
		var s_node: Node = Node.new()
		stats.name = STATS
		t_node.name = TECHNIQUES
		s_node.name = SPELLS
		add_child(stats)
		add_child(t_node)
		add_child(s_node)
		stats.set_owner(_root_node)
		t_node.set_owner(_root_node)
		s_node.set_owner(_root_node)
	else:
		stats = get_node(STATS)
		techniques = get_node(TECHNIQUES).get_children()
		spells = get_node(SPELLS).get_children()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
