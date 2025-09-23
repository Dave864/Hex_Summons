class_name PlayerOptionButton
extends TextureButton
"""
A button that denotes a player option, specifically either technique, spell,
summon, item, or end. Manages the animations associated with selecting this
option.
"""


const COLOR_WHITE: Color = Color.white
const COLOR_GREY: Color = Color("7f7f7f")

export(NodePath) var sigil_ref = NodePath("")
export(NodePath) var icon_ref = NodePath("")

onready var sigil: TextureRect = get_node_or_null(sigil_ref)
onready var icon: TextureRect = get_node_or_null(icon_ref)
onready var label: Label = $Label
onready var ap: AnimationPlayer = get_node_or_null("AnimationPlayer")


# Resets the button.
func reset() -> void:
	if not disabled:
		pressed = false


# Sets the disabled value, updating label and all images to match.
func set_disabled(d: bool = true) -> void:
	disabled = d
	if disabled:
		_update_modulation(COLOR_GREY)
	else:
		_update_modulation(COLOR_WHITE)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_check_for_required_params()
	set_disabled(disabled)


# Updates the modulation for sigil, icon, and label UI elements.
func _update_modulation(m_color: Color) -> void:
	if sigil != null:
		sigil.modulate = m_color
	if icon != null:
		icon.modulate = m_color
	label.modulate = m_color


# Checks that all required parameters have been set.
func _check_for_required_params() -> void:
	pass


# Grabs the focus for the UI.
func _on_PlayerOptionButton_mouse_entered():
	if disabled:
		return
	call_deferred("grab_focus")


# Plays focused animation.
func _on_PlayerOptionButton_focus_entered():
	print("{0} focus entered".format([name]))


func _on_PlayerOptionButton_focus_exited():
	print("{0} focus left".format([name]))


# Plays the appropriate animations when the button is toggled.
func _on_PlayerOptionButton_toggled(button_pressed: bool):
	if button_pressed:
		print("{0} toggled on".format([name]))
	else:
		print("{0} toggled off".format([name]))
