extends MarginContainer
class_name SubOptionsButton
"""
Button that describes a possible sub-option for a given option.
"""


var _action_details: Action = null setget set_action_details, get_action_details


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


# Set the action details for the button.
func set_action_details(a: Action) -> void:
	_action_details = a
	$Button.set_text(_action_details.name)


# Get the action details for the button.
func get_action_details() -> Action:
	return _action_details


# Emit a signal indicating that the button was pressed.
func _on_Button_pressed() -> void:
	print("%s selected" % [_action_details.name])
#	SignalBus.emit_signal("player_action_confirmed", _action_details)


# Emit a signal indicating that the button was hovered over.
func _on_Button_mouse_entered() -> void:
#	print("%s hovered" % [_action_details.name])
	SignalBus.emit_signal("player_action_hovered", _action_details)
