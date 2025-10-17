class_name PlayerOptionButton
extends TextureButton
"""
A button that denotes a player option, specifically either technique, spell,
summon, item, or end. Manages the animations associated with selecting this
option.
"""


const COLOR_WHITE: Color = Color.WHITE
const COLOR_GREY: Color = Color("7f7f7f")

@export var sigil_ref: NodePath = NodePath("")
@export var icon_ref: NodePath = NodePath("")

var _mouse_came_back: bool = false

@onready var sigil: TextureRect = get_node_or_null(sigil_ref)
@onready var icon: TextureRect = get_node_or_null(icon_ref)
@onready var label: Label = $Label
@onready var ap_focus: AnimationPlayer = $APFocus
@onready var ap_icon: AnimationPlayer = $APIcon


# Resets the button.
func reset() -> void:
	if not disabled:
		pressed = false


# Sets the disabled value, updating label and all images to match.
func disable(d: bool = true) -> void:
	disabled = d
	if disabled:
		_update_modulation(COLOR_GREY)
	else:
		_update_modulation(COLOR_WHITE)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_check_for_required_params()
	disable(disabled)


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
func _on_PlayerOptionButton_mouse_entered() -> void:
	if disabled:
		return
	_mouse_came_back = true
	call_deferred("grab_focus")


# Plays focused animation.
func _on_PlayerOptionButton_focus_entered() -> void:
	# Don't do anything if the mouse was still hovering over button when focus
	# came back. Weird animation errors happen.
	if (
		InputController.source_is_keymouse()
		and is_hovered()
		and not _mouse_came_back
	):
		return
	if pressed:
		ap_focus.play("focus_selected")
		ap_icon.play("selected_start")
		await ap_icon.animation_finished
		ap_icon.play("selected_loop")
	else:
		ap_icon.play("selected_start")
		ap_focus.play("focus")


# Resets all animations when focus is gone.
func _on_PlayerOptionButton_focus_exited() -> void:
	_mouse_came_back = false
	if not pressed:
		ap_icon.play("RESET")
	ap_focus.play("RESET")


# Plays the appropriate animations when the button is toggled.
func _on_PlayerOptionButton_toggled(is_toggled: bool) -> void:
	if is_toggled:
		ap_focus.play("focus_selected")
		ap_icon.play("selected_loop")
	elif has_focus():
		ap_focus.play("focus")
		ap_icon.play("selected_start")
	else:
		ap_focus.play("RESET")
		ap_icon.play("RESET")
