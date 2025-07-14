class_name InitiativeTracker
extends HBoxContainer
"""
Displays the current characters in initiative as well as the current active
character. Initiative works by comparing the agility stat of all characters,
and uses that to determine how far each one "travels" in a round. The highest
agility determines the distance needed to travel in order for a character to
take their turn. The number of rounds tracked is equal to the number of
initiative slots in the UI.
"""


export(int, 2, 10) var pity_round_count = 2

var _character_init: Dictionary = {}
var _init_order: Dictionary = {}
var _round_pace: int = 0


# Populates the initiative tracker with character details.
func populate_initiative(characters: Array) -> void:
	for c in characters:
		var c_agility: int = c.stats.get_stat(Stat.Type.AGILITY)
		_character_init[c.get_instance_id()] = {
			"character": c,
			"no_turn_count": 0
		}
		_round_pace = c_agility if _round_pace < c_agility else _round_pace


# Updates the initiative track by the specified step.
func progress_initiative(initiative_step: int = 1) -> void:
	pass


# Updates the display to reflect the current initiative.
func update_display() -> void:
	pass


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var init: int = 0
	var initiative_slots: Array = get_children()
	for slot in initiative_slots:
		slot.update_initiative_lanel(String(init))
		_init_order[init] = []
		init += 1


# Determines the initiative order starting from the specified round.
func _calculate_initiative() -> void:
	for cur_round in _init_order.keys().size():
		if cur_round == 0:
			_calculate_round_zero_initiative()
		_calculate_round_initiative(cur_round)


# Helper for _calculate_inititative. Determines the initiative data for
# round zero.
func _calculate_round_zero_initiative() -> void:
	var characters: Array = []
	var initiative_data: Array = []
	for details in _character_init.values():
		characters.append(details["character"])
	characters.sort_custom(ArraySorters, "sort_character_initiative")
	for i in characters.size():
		var c: Character = characters[i]
		initiative_data.append(
				{
					"c_id": c.get_instance_id(),
					"pace": c.stats.get_stat(Stat.Type.AGILITY),
					"present": true
				}
		)
	_init_order[0] = initiative_data


# Helper for _calculate_inititative. Determines the initiative data for a given
# round.
func _calculate_round_initiative(i_round: int) -> void:
	var initiative_data: Array = _init_order[i_round - 1].duplicate(true)
	for i in initiative_data.size():
		var c: Character = _character_init[initiative_data[i]["c_id"]]
		var c_id = c.get_instance_id()
		initiative_data[i]["pace"] += c.stats.get_stat(Stat.Type.AGILITY)
		if initiative_data[i]["pace"] >= _round_pace:
			initiative_data[i]["present"] = true
			initiative_data[i]["pace"] -= _round_pace
			_character_init[c_id]["no_turn_count"] = 0
		elif _character_init[c_id]["no_turn_count"] >= pity_round_count:
			initiative_data[i]["present"] = true
			initiative_data[i]["pace"] = 0
			_character_init[c_id]["no_turn_count"] = 0
		else:
			initiative_data[i]["present"] = false
			_character_init[c_id]["no_turn_count"] += 1
	_init_order[i_round] = initiative_data


# Updates the initiative tracker to match the change in agility.
func _on_Character_agility_changed(c: Character) -> void:
	var c_agility: int = c.stats.get_stat(Stat.Type.AGILITY)
	var c_id: int = c.get_instance_id()
	_round_pace = c_agility if c_agility > _round_pace else _round_pace
	_calculate_initiative()
	update_display()


# Removes the character from the initiative track when their hp drops tp zero.
func _on_Character_zero_health(c: Character) -> void:
	var c_id: int = c.get_instance_id()
	_character_init.erase(c_id)
	_calculate_initiative()
	update_display()
