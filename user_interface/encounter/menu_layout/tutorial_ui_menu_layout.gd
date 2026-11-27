class_name TutorialUIMenuLayout
extends EncounterUIMenuLayout
## Manages the UI elements of the tutorial scene. Uses a traditional menu layout.
##
## This handles the overall management of the various UI nodes used during the
## tutorial. Also provides a convenient access point for said nodes: 
## InitiativeTracker, StandbyHighlightPool, PartyCharacterStats, and
## PlayerOptionsMenu.


## Indicates that the tutorial step has been updated.
signal step_updated
## Indicates that the UI should be reactivated.
signal reactivated

## Flag indicating the current step of the tutorial
var tutorial_step := Tutorial.Step.INTRO:
	set(value):
		tutorial_step = value
		step_updated.emit()


## Updates the active player being focused on. Does not populate certain option
## menus based on the current step.
func set_focused_character_for_step(new_player: PlayerCharacter) -> void:
	_focused_character = new_player
	_summon_manager.summoner = _focused_character
	_set_highlight_for_focus_character(true)
	_player_options_menu.clear_all_options()
	# Don't display before step 2. TECHNIQUE.
	if tutorial_step < 2:
		_player_options_menu.populate_technique_options([])
	else:
		_player_options_menu.populate_technique_options(
			_focused_character.get_techniques()
		)
	# Don't display before step 3, SPELL.
	_player_options_menu.populate_spell_options(
			[] as Array[Action] if tutorial_step < 3
			else _focused_character.get_spells()
	)
	# Don't displau before step 4, SUMMON.
	_player_options_menu.populate_summon_options(
			null if tutorial_step < 4 else _summon_manager
	)
	# TODO: Add call to get items when items are implemented.
	_player_options_menu.populate_item_options([])
	display_player_menu(true)


## Emits the reactivated signal.
func emit_reactivated() -> void:
	reactivated.emit()
