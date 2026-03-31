@abstract
class_name InitiativeTracker
extends Control
## Base class for initiative tracking. Displays the current characters in
## initiative as well as the current active character.


## The collection of InitiativeSlot objects.
var init_slots: Array[InitiativeSlot]
## The current turn in the round.
var _current_turn: int = 0
## Reference to the summon character.
var _summon: Summon = null

## The animation player for the initiative tracker.
@onready var ap: AnimationPlayer = $AnimationPlayer


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var init: int = 0
	for slot: InitiativeSlot in $InitiativeSlots.get_children():
		init_slots.append(slot)
		slot.update_initiative_label(init)
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
@abstract func populate_initiative(characters: Array[Character]) -> void


## Updates the initiative track by one.
func progress_initiative() -> void:
	# Update the internal initiative data.
	ap.play("shift")
	_update_display()
	await ap.animation_finished


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
@abstract func get_current_character() -> Character


## Gets the character at the next initiative step.
@abstract func get_next_character() -> Character


## Updates the display to reflect the current initiative.
func _update_display() -> void:
	var char_order: Array[Character] = _get_character_order()
	var earliest_init: Dictionary[int, int] = {}
	for character: Character in char_order:
		earliest_init[character.get_instance_id()] = -1
	for i: int in init_slots.size():
		var character: Character = char_order[i]
		init_slots[i].change_character(character)
		if earliest_init[character.get_instance_id()] < 0:
			earliest_init[character.get_instance_id()] = i
			character.character_label.set_initiative_label(i)


## Helper for _update_display. Determines the order that characters will be
## displayed in the initiative tracker.
@abstract func _get_character_order() -> Array[Character]


## Determines the initiative order starting from the current round.
@abstract func _calculate_full_initiative() -> void


## Removes the character from the initiative tracker.
func _remove_character(c: Character) -> void:
	c.stats.disconnect(
			"agility_changed",
			Callable(self, "_on_CharacterStatModifiers_agility_changed")
	)
	# Remove character from initiative tracking structure.


## Updates the initiative tracker to match the change in agility.
@abstract func _on_CharacterStatModifiers_agility_changed(new_agility: int) -> void


## Removes the character from the initiative track when their hp drops tp zero.
func _on_Character_zero_health(c: Character) -> void:
	_remove_character(c)
	_calculate_full_initiative()
	_update_display()


## Updates the intiative tracker display to portray the summon portrait in place
## of the summoner.
func _on_Summon_activated(_summoner_id) -> void:
	_update_display()


## Updates the intiative tracker display to retore the portrait of the summoner.
func _on_Summon_deactivated() -> void:
	_update_display()
