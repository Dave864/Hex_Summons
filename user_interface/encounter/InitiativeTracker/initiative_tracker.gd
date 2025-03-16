class_name InitiativeTracker
extends HBoxContainer
"""
Displays the current characters in initiative as well as the current active character.
"""


var _character_label: PackedScene = preload("res://user_interface/encounter/DisplayPanel/DisplayPanel.tscn")
var _initiative_list: Array = []
var _cur_init: int = 0
var _active_character_ref: ReferenceRect = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_active_character_ref = ReferenceRect.new()
	_active_character_ref.editor_only = false


# Populates the initiative tracker with display labels and positions the reference
func populate_initiative(character_initiative: Array) -> void:
	for character in character_initiative:
		var display_label: DisplayPanel = _character_label.instance()
		display_label.set_text(character.name)
		add_child(display_label)
		_initiative_list.append(display_label)
	_initiative_list[0].add_child(_active_character_ref)


# Moves the active character reference to the specified initiative.
func update_initiative(new_initiative: int) -> void:
	_initiative_list[_cur_init].remove_child(_active_character_ref)
	_initiative_list[new_initiative].add_child(_active_character_ref)
	_cur_init = new_initiative
