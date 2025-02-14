class_name SubOptions
extends ScrollContainer
"""
Manages the SubOptions UI element in the EncounterUI.
"""


onready var _sub_options_container: HBoxContainer = $HBoxContainer


# Populate the sub-options container.
func populate_sub_options(contents: Array) -> void:
	for item in contents:
		"""
		TODO: Connect the appropriate signals
		"""
		var new_button = Button.new()
		new_button.text = item.name
		_sub_options_container.add_child(new_button)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
