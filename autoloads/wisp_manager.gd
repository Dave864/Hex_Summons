extends Node
"""
Tracks the condition of all wisps, whether they are set to a player and what
state they are in during an encounter.
"""


var earth: Dictionary = {}
var fire: Dictionary = {}
var water: Dictionary = {}
var wind: Dictionary = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Gets all earth wisps, initializing their status.
func _load_earth() -> void:
	pass


# Gets all fire wisps, initializing their status.
func _load_fire() -> void:
	pass
