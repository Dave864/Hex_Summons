extends Button


func _on_Button_polarity_left_pressed() -> void:
	ElementalPolarity.invert_left_polarities()


func _on_Button_polarity_right_pressed() -> void:
	ElementalPolarity.invert_right_polarities()


func _on_Button_polarity_invert_pressed() -> void:
	ElementalPolarity.invert_all_polarities()


func _on_Button_polarity_cw_pressed() -> void:
	ElementalPolarity.shift_polarities_cw()


func _on_Button_polarity_ccw_pressed() -> void:
	ElementalPolarity.shift_polarities_ccw()
