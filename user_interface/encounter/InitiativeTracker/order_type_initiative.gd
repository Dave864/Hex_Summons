class_name OrderTypeInitiative
extends InitiativeTracker
## Displays the current characters in initiative as well as the current active
## character. Uses an order initiative system.
##
## An order initiative simply places all characters in order according to their
## agility value. Higher values go first. Tracks the order and who has acted
## in the round.


## The order of characters in a round.
var _init_order: Array[Character]
## The index of the currently active character.
var _current_index: int
## Tracks which characters have acted in the current round. Uses character
## instance id as the key.
var _character_tracker: Dictionary[int, bool]


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()


## Populates the initiative tracker with character details.
func populate_initiative(characters: Array[Character]) -> void:
	_current_index = 0
	_init_order.resize(characters.size())
	for i: int in characters.size():
		_init_order[i] = characters[i]
		_character_tracker[characters[i].get_instance_id()] = false
		characters[i].stats.connect(
				"agility_changed",
				Callable(self, "_on_CharacterStatModifiers_agility_changed")
		)
		characters[i].connect(
				"defeated",
				Callable(self, "_on_Character_defeated")
		)
	_calculate_full_initiative()
	_update_display()


## Updates the initiative track by one.
func progress_initiative() -> void:
	if _current_index + 1 >= _init_order.size():
		_reset_initiative()
		super.progress_initiative()
		return
	_character_tracker[get_current_character().get_instance_id()] = true
	var next_character: Character
	for i: int in _init_order.size():
		next_character = _init_order[i]
		if not _character_tracker[next_character.get_instance_id()]:
			_current_index = i
			super.progress_initiative()
			return
	super.progress_initiative()


## Gets the character at the current initiative step.
func get_current_character() -> Character:
	return _init_order[_current_index]


## Gets the character at the next initiative step.
func get_next_character() -> Character:
	if _current_index + 1 >= _init_order.size():
		return _init_order[0]
	var next_character: Character
	for i: int in _init_order.size():
		if i == _current_index:
			continue
		next_character = _init_order[i]
		if not _character_tracker[next_character.get_instance_id()]:
			return next_character
	return get_current_character()


## Resets the current index and character tracker.
func _reset_initiative() -> void:
	_current_index = 0
	for character_key: int in _character_tracker.keys():
		_character_tracker[character_key] = false


## Helper for _update_display. Determines the order that characters will be
## displayed in the initiative tracker.
func _get_character_order() -> Array[Character]:
	var char_order: Array[Character] = []
	char_order.resize(init_slots.size())
	char_order[0] = _summon_check(get_current_character())
	var order_index: int = 1
	for character: Character in _init_order:
		if character == get_current_character():
			continue
		elif not _character_tracker[character.get_instance_id()]:
			char_order[order_index] = _summon_check(character)
			order_index += 1
			if order_index >= char_order.size():
				return char_order
	while order_index < char_order.size():
		for character: Character in _init_order:
			char_order[order_index] = _summon_check(character)
			order_index += 1
			if order_index >= char_order.size():
				break
	return char_order


## Checks if the summon should be used in place of the character, returning the
## character that should be used.
func _summon_check(character: Character) -> Character:
	if (
		_summon.is_active() 
		and _summon.summoner.get_instance_id() == character.get_instance_id()
	):
		return _summon
	else:
		return character


## Determines the initiative order starting from the current round.
func _calculate_full_initiative() -> void:
	_init_order.sort_custom(ArraySorters.sort_character_initiative)


## Removes the character from the initiative tracker.
func _remove_character(c: Character) -> void:
	super._remove_character(c)
	var current_character: Character = get_current_character()
	if c == current_character:
		current_character = get_next_character()
	_character_tracker.erase(c.get_instance_id())
	_init_order.erase(c)
	_current_index = _init_order.bsearch_custom(
			current_character,
			ArraySorters.sort_character_initiative
	)


## Updates the initiative tracker to match the change in agility.
func _on_CharacterStatModifiers_agility_changed(_new_agility: int) -> void:
	_calculate_full_initiative()
	_update_display()
