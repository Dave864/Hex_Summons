class_name ThreatTracker
extends Object
"""
Tracks the threat level of various characters with respect to an observer
character.
"""


var _observer_char: Character = null
var _threat_values: Dictionary = {} setget , get_threat_values


# Returns the threat values recorded by the observer.
func get_threat_values() -> Dictionary:
	return _threat_values


# Initializes the object.
func _init(observer: Character, target_characters: Array) -> void:
	_observer_char = observer
	for t_char in target_characters:
		_threat_values[t_char.get_instance_id()] = 0.0
