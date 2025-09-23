class_name MovementButton
extends PlayerOptionButton
"""
A button that denotes the movement player option. Manages the button animations
associated with selecting this option.
"""


# Grabs the focus for the UI.
func _on_MovementButton_mouse_entered():
	if disabled:
		return
	call_deferred("grab_focus")


# Plays focused animation.
func _on_MovementButton_focus_entered():
	print("{0} focus entered".format([name]))


# Toggles the Movement button off when focus has shifted to a new Control item.
func _on_MovementButton_focus_exited():
	print("{0} focus left".format([name]))


# Keeps the Movement button toggled on when it is in focus.
func _on_MovementButton_toggled(button_pressed: bool):
	if button_pressed:
		print("{0} toggled on".format([name]))
	if has_focus():
		set_pressed_no_signal(true)
	else:
		print("{0} toggled off".format([name]))
