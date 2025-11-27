class_name MovementButton
extends PlayerOptionButton
## A button that denotes the movement player option.
##
## Manages the button animations associated with selecting this option.


## Grabs the focus for the UI.
func _on_MovementButton_mouse_entered() -> void:
	if disabled:
		return
	grab_focus.call_deferred()


## Plays focus animation.
func _on_MovementButton_focus_entered() -> void:
	if button_pressed:
		ap_focus.play("focus_selected")
	else:
		ap_focus.play("focus")


## Toggles the Movement button off when focus has shifted to a new Control item.
func _on_MovementButton_focus_exited() -> void:
	ap_focus.play("RESET")
	if not button_pressed:
		ap_icon.play("RESET")


## Keeps the Movement button toggled on when it is in focus.
func _on_MovementButton_toggled(is_toggled: bool) -> void:
	if is_toggled:
		ap_focus.play("focus_selected")
		ap_icon.play("selected_start")
		await ap_icon.animation_finished
		ap_icon.play("selected_loop")
	elif has_focus():
		set_pressed_no_signal(true)
	else:
		ap_focus.play("RESET")
		ap_icon.play("RESET")
