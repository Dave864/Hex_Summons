class_name MovementButton
extends PlayerOptionButton
"""
A button that denotes the movement player option. Manages the button animations
associated with selecting this option.
"""


onready var ap_focus: AnimationPlayer = $APFocus
onready var ap_icon: AnimationPlayer = $APIcon


# Grabs the focus for the UI.
func _on_MovementButton_mouse_entered():
	if disabled:
		return
	call_deferred("grab_focus")


# Plays focus animation.
func _on_MovementButton_focus_entered():
	if pressed:
		ap_focus.play("focus_selected")
	else:
		ap_focus.play("focus")


# Toggles the Movement button off when focus has shifted to a new Control item.
func _on_MovementButton_focus_exited():
	print("MovementButton focus exited")
	ap_focus.play("RESET")
	if not pressed:
		ap_icon.play("RESET")


# Keeps the Movement button toggled on when it is in focus.
func _on_MovementButton_toggled(button_pressed: bool):
	if button_pressed:
		ap_icon.play("selected_start")
		yield(ap_icon, "animation_finished")
		ap_icon.play("selected_loop")
	elif has_focus():
		set_pressed_no_signal(true)
		ap_focus.play("focus_selected")
	else:
		ap_icon.play("RESET")
		ap_focus.play("RESET")
