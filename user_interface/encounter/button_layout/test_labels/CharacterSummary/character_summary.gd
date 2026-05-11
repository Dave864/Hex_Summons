class_name CharacterSummary
extends VBoxContainer
## Displays a summary of the listed character.


const ELEMENT_TAGS: Dictionary[Element.Type, String] = {
	Element.Type.EARTH: "E",
	Element.Type.FIRE: "F",
	Element.Type.WATER: "Wt",
	Element.Type.WIND: "Wd",
}


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_check_for_required_parameters()


## Sets the name of the summary.
func set_character_name(new_name: String) -> void:
	$Name.text = new_name


## Sets the hp values of the summary.
func set_hp(cur_hp: int, max_hp: int) -> void:
	$HP.text = "%d/%d" % [cur_hp, max_hp]


## Sets the wisp counts of the summary for a player character.
func set_player_wisp_count(wisp_pool: PlayerWispPool) -> void:
	var text_format: String = (
		"L: {0}\n" \
		+ "{1}: {2}, {3}: {4}\n" \
		+ "{5}: {6}, {7}: {8}\n" \
		+ "D: {9}"
	)
	var l_elems: Array[Element.Core] = ElementalAlignment.get_light_elements()
	var d_elems: Array[Element.Core] = ElementalAlignment.get_dark_elements()
	$WispCount.text = text_format.format(
			[
				wisp_pool.active_light_count(),
				ELEMENT_TAGS[l_elems[0]],
				wisp_pool.active_element_count(l_elems[0] as Element.Type),
				ELEMENT_TAGS[l_elems[1]],
				wisp_pool.active_element_count(l_elems[1] as Element.Type),
				ELEMENT_TAGS[d_elems[0]],
				wisp_pool.active_element_count(d_elems[0] as Element.Type),
				ELEMENT_TAGS[d_elems[1]],
				wisp_pool.active_element_count(d_elems[1] as Element.Type),
				wisp_pool.active_dark_count()
			]
	)


## Sets the wisp counts of the summary for an enemy character.
func set_enemy_wisp_count() -> void:
	$WispCount.text = ""


## Aligns the label text.
func set_text_alignment(text_alignment: int) -> void:
	if (
		text_alignment == HORIZONTAL_ALIGNMENT_LEFT
		or text_alignment == HORIZONTAL_ALIGNMENT_CENTER
		or text_alignment == HORIZONTAL_ALIGNMENT_RIGHT
	):
		$Name.horizontal_alignment = text_alignment
		$HP.horizontal_alignment = text_alignment
		$WispCount.horizontal_alignment = text_alignment
	else:
		$Name.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		$HP.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		$WispCount.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT


## Updates the hp values when a character's health is changed.
func _on_Character_hp_changed(new_hp: int, cur_hp: int) -> void:
	set_hp(new_hp, cur_hp)


## Checks that all required parameters are set.
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
			"CharacterSummary is missing an HP node."
	)
	assert(
			get_node("HP") is Label,
			"CharacterSummary HP node is not a Label."
	)
	assert(
			get_node_or_null("WispCount") != null,
			"CharacterSummary is missing a WispCount node."
	)
	assert(
			get_node("WispCount") is Label,
			"CharacterSummary WispCount node is not a Label."
	)
