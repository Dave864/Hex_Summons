class_name InitiativeTracker
extends Control
## Displays the current characters in initiative as well as the current active
## character.
##
## Initiative works by comparing the agility stat of all characters,
## and uses that to determine how far each one "travels" in a round. The highest
## agility determines the distance needed to travel in order for a character to
## take their turn. The number of rounds tracked is equal to the number of
## initiative slots in the UI.


## Tracks the number of rounds a character has gone without a turn.
class NoTurnTracker:
	## The character node.
	var character: Character = null
	## The number of rounds a character has gone without a turn
	var inaction_count: int = 0
	
	
	func _init(character_ref: Character) -> void:
		character = character_ref
		inaction_count = 0


## Describes the details of a single turn.
class TurnDetails:
	## The id of the character allotted to this turn.
	var c_id: int = 0
	## The current progress towards the round pace.
	var progress: int = 0
	## Whether the character is active in the round this turn is in.
	var is_present: bool = false
	
	
	func _init(
		character_id: int,
		start_progress: int = 0,
		presence_state: bool = true
	) -> void:
		c_id = character_id
		progress = start_progress
		is_present = presence_state


## Describes the turns in a round.
class RoundDetails:
	## Tracks the turns of the round.
	var _round_data: Array[TurnDetails] = []
	
	
	## Returns the number of turns in the round.
	func turn_count() -> int:
		return _round_data.size()
	
	
	## Adds turn details to the end of the round.
	func add_turn_details(turn_details: TurnDetails) -> void:
		_round_data.append(turn_details)
	
	
	## Gets the details for a given turn.
	func details_for_turn(turn: int) -> TurnDetails:
		return _round_data[turn]


## The maximimum number of consecutive rounds a character can go without a turn.
@export_range(2, 10) var pity_round_count: int = 2

## The collection of InitiativeSlot objects.
var init_slots: Array[InitiativeSlot]
## Tracks the character and number of rounds said character has gone without
## taking a turn. The character instance id is used as the key.
var _c_pity_tracker: Dictionary[int, NoTurnTracker] = {}
## Stores the initiative details of a number of rounds equal to the number of
## initiative slot UI elements. The keys are the rounds, starting at round 0.
## Each round stores an Array which contains the character initiative details.
var _init_order: Dictionary[int, RoundDetails] = {}
## The current turn in the round.
var _current_turn: int = 0
## The "distance" a character must travel in a round to take their turn.
var _round_pace: int = 0
## The maximum number of turns that can take place in a round.
var _round_turns: int = 0
## Reference to the summon character.
var _summon: Summon = null

@onready var ap: AnimationPlayer = $AnimationPlayer
## The maximum number of rounds that are tracked.
@onready var _max_rounds: int = $InitiativeSlots.get_child_count()


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var init: int = 0
	for slot: InitiativeSlot in $InitiativeSlots.get_children():
		init_slots.append(slot)
		slot.update_initiative_label(init)
		_init_order[init] = RoundDetails.new()
		init += 1


## Updates the summon character reference.
func set_summon_reference(new_summon: Summon) -> void:
	if _summon != null:
		_summon.disconnect("activated", Callable(self, "_on_Summon_activated"))
		_summon.disconnect(
				"deactivated",
				Callable(self, "_on_Summon_deactivated")
		)
	_summon = new_summon
	_summon.connect("activated", Callable(self, "_on_Summon_activated"))
	_summon.connect("deactivated", Callable(self, "_on_Summon_deactivated"))


## Populates the initiative tracker with character details.
func populate_initiative(characters: Array[Character]) -> void:
	_round_turns = characters.size()
	for c: Character in characters:
		_c_pity_tracker[c.get_instance_id()] = NoTurnTracker.new(c)
		ErrorUtil.connect_signal(
				c.stats,
				"agility_changed",
				self,
				"_on_CharacterStatModifiers_agility_changed"
		)
	_determine_round_pace()
	_calculate_full_initiative()
	_update_display()


## Updates the initiative track by one. Returns true when completed, allowing
## for the use of the 'await' keyword when called.
func progress_initiative() -> bool:
	_current_turn = _get_next_init_step()
	# Initiative goes to the next round if _current_turn is negative.
	if _current_turn < 0:
		# Character in first turn of round always goes as they set the pace.
		_current_turn = 0
		# The current round zero has completed, need to shift the remaining
		# rounds up one.
		for round_number: int in range(_init_order.size() - 1):
			_init_order[round_number] = _init_order[round_number + 1]
		_calculate_round_initiative(_init_order.size() - 1)
	ap.play("shift")
	_update_display()
	await ap.animation_finished
	return true


## Called during the "shift" animation. Sets the initiative labels to the
## previous value.
func preceding_init_labels() -> void:
	for i in init_slots.size() - 1:
		init_slots[i].update_initiative_label(i + 1)


## Called during the "shift" animation. Sets the initiative labels to the current
## value.
func current_init_labels() -> void:
	for i in init_slots.size() - 1:
		init_slots[i].update_initiative_label(i)


## Gets the character at the current initiative step.
func get_current_character() -> Character:
	var c_id: int = _init_order[0].details_for_turn(_current_turn).c_id
	return _c_pity_tracker[c_id].character


## Gets the character at the next initiative step.
func get_next_character() -> Character:
	var next_turn: int = _get_next_init_step()
	var c_id: int
	# Initiative goes to next round.
	if next_turn < 0:
		# Character in first turn of round always goes as they set the pace.
		c_id = _init_order[1].details_for_turn(0).c_id
	else:
		c_id = _init_order[0].details_for_turn(next_turn).c_id
	return _c_pity_tracker[c_id].character


## Determines the round pace based on the current characters.
func _determine_round_pace() -> void:
	_round_pace = 0
	for details: NoTurnTracker in _c_pity_tracker.values():
		var c: Character = details.character
		var c_agility: int = c.stats.get_stat(Stat.Type.AGILITY)
		_round_pace = c_agility if _round_pace < c_agility else _round_pace


## Determines the next step in the round when a character takes a turn.
## Returns -1 if the next step is the first index of the next round.
func _get_next_init_step() -> int:
	for i: int in range(_current_turn + 1, _round_turns):
		if _init_order[0].details_for_turn(i).is_present:
			return i
	return -1


## Updates the display to reflect the current initiative.
func _update_display() -> void:
	var char_order: Array[Character] = []
	char_order.resize(init_slots.size())
	_populate_display_data(char_order)
	var earliest_init: Dictionary[int, int] = {}
	for character: Character in char_order:
		earliest_init[character.get_instance_id()] = -1
	for i: int in init_slots.size():
		var character: Character = char_order[i]
		init_slots[i].change_character(character)
		if earliest_init[character.get_instance_id()] < 0:
			earliest_init[character.get_instance_id()] = i
			character.character_label.set_initiative_label(i)


## Helper for _update_display. Populates the char_order array with the characters
## that will go next from the current round initiative.
func _populate_display_data(char_order: Array) -> void:
	var init_step: int = _current_turn
	var c_index: int = 0
	for round_number: int in _max_rounds:
		for i: int in range(init_step, _round_turns):
			var turn: TurnDetails = _init_order[round_number].details_for_turn(i)
			if not turn.is_present:
				continue
			var c_id: int = turn.c_id
			if (
				_summon.is_active()
				and _summon.summoner.get_instance_id() == c_id
			):
				char_order[c_index] = _summon
			else:
				char_order[c_index] = _c_pity_tracker[c_id].character
			c_index += 1
			if c_index >= char_order.size():
				return
		# Start looking at first turn in next round.
		init_step = 0


## Determines the initiative order starting from the specified round.
func _calculate_full_initiative() -> void:
	for cur_round in _init_order.size():
		if cur_round == 0:
			_calculate_round_zero_initiative()
		else:
			_calculate_round_initiative(cur_round)


## Helper for _calculate_inititative. Determines the initiative data for
## round zero.
func _calculate_round_zero_initiative() -> void:
	var characters: Array[Character] = []
	var round_data := RoundDetails.new()
	for details: NoTurnTracker in _c_pity_tracker.values():
		characters.append(details.character)
	characters.sort_custom(Callable(ArraySorters, "sort_character_initiative"))
	for i: int in characters.size():
		var c: Character = characters[i]
		var character_turn_details := TurnDetails.new(
				c.get_instance_id(),
				c.stats.get_stat(Stat.Type.AGILITY)
		)
		round_data.add_turn_details(character_turn_details)
	_init_order[0] = round_data


## Helper for _calculate_inititative. Determines the initiative data for a given
## round.
func _calculate_round_initiative(round_number: int) -> void:
	var old_round_data: RoundDetails = _init_order[round_number - 1]
	var new_round_data := RoundDetails.new()
	for turn: int in old_round_data.turn_count():
		var c_id = old_round_data.details_for_turn(turn).c_id
		var c: Character = _c_pity_tracker[c_id].character
		var turn_data := TurnDetails.new(
				c_id,
				old_round_data.details_for_turn(turn).progress,
				old_round_data.details_for_turn(turn).is_present
		)
		turn_data.progress += c.stats.get_stat(Stat.Type.AGILITY)
		if turn_data.progress >= _round_pace:
			turn_data.is_present = true
			turn_data.progress -= _round_pace
			_c_pity_tracker[c_id].inaction_count = 0
		elif _c_pity_tracker[c_id].inaction_count >= pity_round_count:
			turn_data.is_present = true
			turn_data.progress = 0
			_c_pity_tracker[c_id].inaction_count = 0
		else:
			turn_data.is_present = false
			_c_pity_tracker[c_id].inaction_count += 1
		new_round_data.add_turn_details(turn_data)
	_init_order[round_number] = new_round_data


## Removes the character from the initiative tracker.
func _remove_character(c: Character) -> void:
	c.stats.disconnect(
			"agility_changed",
			Callable(self, "_on_CharacterStatModifiers_agility_changed")
	)
	var c_id: int = c.get_instance_id()
	var c_round_init: int = _get_character_round_init(c_id)
	_c_pity_tracker[c_id].free()
	_c_pity_tracker.erase(c_id)
	for rd in _init_order.size():
		_init_order[rd].pop_at(c_round_init)
	# If the round tracker was referencing the last character, need to shift it
	# left to keep the index valid.
	_round_turns -= 1
	if _current_turn >= _round_turns:
		_current_turn = _round_turns - 1
	_determine_round_pace()


## Helper for _remove_character. Gets the round initiative of the character.
func _get_character_round_init(c_id: int) -> int:
	var rd_i = 0
	for i in _init_order[0].size():
		if _init_order[0][i]["c_id"] == c_id:
			rd_i = i
	return rd_i


## Updates the initiative tracker to match the change in agility.
func _on_CharacterStatModifiers_agility_changed(new_agility: int) -> void:
	_round_pace = new_agility if new_agility > _round_pace else _round_pace
	_calculate_full_initiative()
	_update_display()


## Removes the character from the initiative track when their hp drops tp zero.
func _on_Character_zero_health(c: Character) -> void:
	_remove_character(c)
	_calculate_full_initiative()
	_update_display()


## Updates the intiative tracker display to portray the summon portrait in place
## of the summoner.
func _on_Summon_activated() -> void:
	_update_display()


## Updates the intiative tracker display to retore the portrait of the summoner.
func _on_Summon_deactivated() -> void:
	_update_display()
