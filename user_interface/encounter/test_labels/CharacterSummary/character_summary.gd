class_name CharacterSummary
extends VBoxContainer
"""
Displays a summary of the listed character.
"""


# Sets the name of the summary.
func set_name(new_name: String) -> void:
	$Name.text = new_name


# Sets the hp values of the summary.
func set_hp(cur_hp: int, max_hp: int) -> void:
	$HP.text = "%d/%d" % [cur_hp, max_hp]


# Aligns the label text.
func set_text_alignment(alignment: int) -> void:
	if (
		alignment == Label.ALIGN_LEFT
		or alignment == Label.ALIGN_CENTER
		or alignment == Label.ALIGN_RIGHT
	):
		$Name.set_align(alignment)
		$HP.set_align(alignment)
	else:
		$Name.set_align(Label.ALIGN_LEFT)
		$HP.set_align(Label.ALIGN_LEFT)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_check_for_required_parameters()


# Updates the hp values when a character's health is changed.
func _on_Character_hp_changed(new_hp: int, cur_hp: int) -> void:
	set_hp(new_hp, cur_hp)


# Checks that all required parameters are set.
func _check_for_required_parameters() -> void:
	assert(
			get_node_or_null("Name") != null,
			"CharacterSummary is missing a Name node."
	)
	assert(
			get_node("Name") is Label,
			"CharacterSummary Name node is not a Label."
	)
	assert(
			get_node_or_null("HP") != null,
			"CharacterSummary is missing an HP node"
	)
	assert(
			get_node("HP") is Label,
			"CharacterSummary HP node is not a Label."
	)
