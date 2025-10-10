class_name AnimatedLabel
extends Label
"""
A label with a special animation that plays when the text is changed.
"""


# Updates the text while playing the "change" animation.
func update_text(new_text: String) -> void:
	text = new_text
	$AnimationPlayer.play("change")


func _ready() -> void:
	$AnimationPlayer.play("RESET")
