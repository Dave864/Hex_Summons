class_name CharacterSummary
extends VBoxContainer
"""
Displays a summary of the listed character.
"""


func set_name(new_name: String) -> void:
	$Name.text = new_name


func set_hp(cur_hp: int, max_hp: int) -> void:
	$HP.text = "%d/%d" % [cur_hp, max_hp]


func set_text_alignment(alignment: int) -> void:
	match alignment:
		Label.ALIGN_LEFT:
			$Name.set_align(Label.ALIGN_LEFT)
			$HP.set_align(Label.ALIGN_LEFT)
		Label.ALIGN_CENTER:
			$Name.set_align(Label.ALIGN_CENTER)
			$HP.set_align(Label.ALIGN_CENTER)
		Label.ALIGN_RIGHT:
			$Name.set_align(Label.ALIGN_RIGHT)
			$HP.set_align(Label.ALIGN_RIGHT)
		_:
			$Name.set_align(Label.ALIGN_LEFT)
			$HP.set_align(Label.ALIGN_LEFT)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_Character_hp_changed(new_hp: int, cur_hp: int) -> void:
	set_hp(new_hp, cur_hp)
