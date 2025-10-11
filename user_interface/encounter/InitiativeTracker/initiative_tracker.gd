class_name InitiativeTracker
extends Control
"""
Displays the current characters in initiative as well as the current active
character. Initiative works by comparing the agility stat of all characters,
and uses that to determine how far each one "travels" in a round. The highest
agility determines the distance needed to travel in order for a character to
take their turn. The number of rounds tracked is equal to the number of
initiative slots in the UI.
"""


export(int, 2, 10) var pity_round_count = 2

# Tracks the character and number of rounds said character has gone without
# taking a turn using the instance id as the key. Each entry has the
# following details:
# "character": <character reference>
# "no_turn_count": <number of turns passed where character did not act>
var _c_pity_tracker: Dictionary = {}
# Stores the initiative details of a number of rounds equal to the number of
# initiative slot UI elements. The keys are the rounds, starting at round 0.
# Each round stores an Array which contains the character initiative details.
# The details are stored as a Dictionary with the keys:
# "cid": <the id of the character>
# "pace": <the current progress towards round_pace>
# "present": <is the character active in the round>
var _init_order: Dictionary = {}
var _cur_init: int = 0
var _round_pace: int = 0
var _round_turns: int = 0

onready var init_slots: Array = $InitiativeSlots.get_children()
onready var ap: AnimationPlayer = $AnimationPlayer


# Populates the initiative tracker with character details.
func populate_initiative(characters: Array) -> void:
	_round_turns = characters.size()
	for c in characters:
		_c_pity_tracker[c.get_instance_id()] = {
			"character": c,
			"no_turn_count": 0
		}
		ErrorUtil.connect_signal(
				c.stats,
				"agility_changed",
				self,
				"_on_CharacterStats_agility_changed"
		)
	_determine_round_pace()
	_calculate_full_initiative()
	_update_display()


# Updates the initiative track by one.
func progress_initiative() -> void:
	_cur_init = _get_next_init_step()
	# Initiative goes to the next round.
	if _cur_init < 0:
		# Character in first turn of round always goes as they set the pace.
		_cur_init = 0
		# The current round zero has completed, need to shift the remaining
		# rounds up one.
		for rd in range(_init_order.size() - 1):
			_init_order[rd] = _init_order[rd + 1]
		_calculate_round_initiative(_init_order.size() - 1)
	ap.play("shift")
	_update_display()
	yield(ap, "animation_finished")


# Called during the "shift" animation. Sets the initiative labels to the previous
# value.
func preceding_init_labels() -> void:
	for i in init_slots.size() - 1:
		init_slots[i].update_initiative_label(i + 1)


# Called during the "shift" animation. Sets the initiative labels to the current
# value.
func current_init_labels() -> void:
	for i in init_slots.size() - 1:
		init_slots[i].update_initiative_label(i)


# Gets the character at the current initiative step.
func get_current_character() -> Character:
	var c_id: int = _init_order[0][_cur_init]["c_id"]
	return _c_pity_tracker[c_id]["character"]


# Gets the character at the next initiative step.
func get_next_character() -> Character:
	var next_init: int = _get_next_init_step()
	var c_id: int
	# Initiative goes to next round.
	if next_init < 0:
		# Character in first turn of round always goes as they set the pace.
		c_id = _init_order[1][0]["c_id"]
	else:
		c_id = _init_order[0][next_init]["c_id"]
	return _c_pity_tracker[c_id]["character"]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var init: int = 0
	for slot in init_slots:
		slot.update_initiative_label(init)
		_init_order[init] = []
		init += 1


# Determines the round pace based on the current characters.
func _determine_round_pace() -> void:
	_round_pace = 0
	for details in _c_pity_tracker.values():
		var c: Character = details["character"]
		var c_agility: int = c.stats.get_stat(Stat.Type.AGILITY)
		_round_pace = c_agility if _round_pace < c_agility else _round_pace


# Determines the next step in the round where a character takes a turn.
# Returns -1 if the next step is the first index of the next round.
func _get_next_init_step() -> int:
	for i in range(_cur_init + 1, _round_turns):
		if _init_order[0][i]["present"]:
			return i
	return -1


# Updates the display to reflect the current initiative.
func _update_display() -> void:
	var char_order: Array = []
	var earliest_init: Dictionary = {}
	for c_id in _c_pity_tracker.keys():
		earliest_init[c_id] = -1
	char_order.resize(init_slots.size())
	_populate_display_data(char_order)
	for i in init_slots.size():
		var c: Character = char_order[i]
		init_slots[i].change_character(c)
		if earliest_init[c.get_instance_id()] < 0:
			earliest_init[c.get_instance_id()] = i
			c.character_label.set_initiative_label(i)


# Helper for _update_display. Populates the char_order array with the characters
# that will go next from the current round initiative.
func _populate_display_data(char_order: Array) -> void:
	var init_step: int = _cur_init
	var round_index: int = 0
	var c_index: int = 0
	while true:
		for i in range(init_step, _round_turns):
			if _init_order[round_index][i]["present"]:
				var c_id: int = _init_order[round_index][i]["c_id"]
				char_order[c_index] = _c_pity_tracker[c_id]["character"]
				c_index += 1
				if c_index >= char_order.size():
					return
		init_step = 0
		round_index += 1


# Determines the initiative order starting from the specified round.
func _calculate_full_initiative() -> void:
	for cur_round in _init_order.size():
		if cur_round == 0:
			_calculate_round_zero_initiative()
		else:
			_calculate_round_initiative(cur_round)


# Helper for _calculate_inititative. Determines the initiative data for
# round zero.
func _calculate_round_zero_initiative() -> void:
	var characters: Array = []
	var initiative_data: Array = []
	for details in _c_pity_tracker.values():
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
		var c: Character = _c_pity_tracker[initiative_data[i]["c_id"]]["character"]
		var c_id = c.get_instance_id()
		initiative_data[i]["pace"] += c.stats.get_stat(Stat.Type.AGILITY)
		if initiative_data[i]["pace"] >= _round_pace:
			initiative_data[i]["present"] = true
			initiative_data[i]["pace"] -= _round_pace
			_c_pity_tracker[c_id]["no_turn_count"] = 0
		elif _c_pity_tracker[c_id]["no_turn_count"] >= pity_round_count:
			initiative_data[i]["present"] = true
			initiative_data[i]["pace"] = 0
			_c_pity_tracker[c_id]["no_turn_count"] = 0
		else:
			initiative_data[i]["present"] = false
			_c_pity_tracker[c_id]["no_turn_count"] += 1
	_init_order[i_round] = initiative_data


# Removes the character from the initiative tracker.
func _remove_character(c: Character) -> void:
	c.stats.disconnect(
			"agility_changed",
			self,
			"_on_CharacterStats_agility_changed"
	)
	var c_id: int = c.get_instance_id()
	var c_round_init: int = _get_character_round_init(c_id)
	_c_pity_tracker.erase(c_id)
	for rd in _init_order.size():
		_init_order[rd].pop_at(c_round_init)
	# If the round tracker was referencing the last character, need to shift it
	# left to keep the index valid.
	_round_turns -= 1
	if _cur_init >= _round_turns:
		_cur_init = _round_turns - 1
	_determine_round_pace()


# Helper for _remove_character. Gets the round initiative of the character.
func _get_character_round_init(c_id: int) -> int:
	var rd_i = 0
	for i in _init_order[0].size():
		if _init_order[0][i]["c_id"] == c_id:
			rd_i = i
	return rd_i


# Updates the initiative tracker to match the change in agility.
func _on_CharacterStats_agility_changed(new_agility: int) -> void:
	_round_pace = new_agility if new_agility > _round_pace else _round_pace
	_calculate_full_initiative()
	_update_display()


# Removes the character from the initiative track when their hp drops tp zero.
func _on_Character_zero_health(c: Character) -> void:
	_remove_character(c)
	_calculate_full_initiative()
	_update_display()
