class_name OptionData
extends Panel
## A panel that displays the details of an action.
##
## Able to show details for techniques and spells.


## The panel display for the range of the action.
@onready var _range_display: RangeDisplay = $RangeDisplay
## The label that describes the cost for the action, either cooldown or wisp.
@onready var _cost_label: Label = $Cost


## Updates the display with the details of the action.
func update_action(new_action: Action) -> void:
	_range_display.update_action(new_action)
	var cooldown_node: Cooldown = new_action.get_node_or_null("Cooldown")
	if cooldown_node != null:
		_cost_label.text = get_cooldown_text(cooldown_node)
		return
	var wisp_cost_node: WispCost = new_action.get_node_or_null("WispCost")
	if wisp_cost_node != null:
		_cost_label.text = get_wisp_cost_text(wisp_cost_node)
		return


## Updates the display with the details of the technique.
func update_for_technique(new_technique: Action) -> void:
	_range_display.update_action(new_technique)
	var cooldown_node: Cooldown = new_technique.get_node_or_null("Cooldown")
	if cooldown_node != null:
		_cost_label.text = get_cooldown_text(cooldown_node)
	else:
		printerr("Technique is missing a Cooldown node.")


## Updates the display with the details of the spell.
func update_for_spell(new_spell: Action) -> void:
	_range_display.update_action(new_spell)
	var wisp_cost_node: WispCost = new_spell.get_node_or_null("WispCost")
	if wisp_cost_node != null:
		_cost_label.text = get_wisp_cost_text(wisp_cost_node)
	else:
		printerr("Spell is missing a WispCost node.")


## Updates the display with the details of a summon's spawn action.
func update_for_summon(spawn_action: Action) -> void:
	_range_display.update_action(spawn_action)
	var wisp_cost_node: WispCost = spawn_action.get_node_or_null("WispCost")
	if wisp_cost_node != null:
		_cost_label.text = get_wisp_cost_text(wisp_cost_node) + "\n"
	else:
		printerr("Spell is missing a WispCost node.")
	_cost_label.text += spawn_action.name


## Creates a string that describes the cooldown for an action.
func get_cooldown_text(cooldown: Cooldown) -> String:
	var text: String = "cooldown: {0}/{1}"
	return text.format(
			[
				cooldown.turn_count - cooldown.get_countdown(),
				cooldown.turn_count
			]
	)

## Creates a string that describes the wisp cost for an action.
func get_wisp_cost_text(wc: WispCost) -> String:
	var text: String = "wisp cost"
	for element in wc.cost_summary:
		text += "\n{0} {1} -{2}-".format(
				[
					Element.Type.find_key(element),
					wc.req_summary[element],
					wc.cost_summary[element]
				]
		)
	for element in wc.req_summary:
		if not wc.cost_summary.has(element):
			text += "\n{0} {1}".format(
					[
						Element.Type.find_key(element),
						wc.req_summary[element]
					]
			)
	return text


## Updates the data details to reflect the highlighted action.
func _on_ActionOptionButton_action_highlighted(action: Action) -> void:
	update_action(action)


## Updates the data details to reflect the highlighted technique.
func _on_TechniqueOptionButton_action_highlighted(action: Action) -> void:
	update_for_technique(action)


## Updates the data details to reflect the highlighted spell.
func _on_SpellOptionButton_action_highlighted(action: Action) -> void:
	update_for_spell(action)


## Updates the data details to reflect the spawn action of the highlighted summon.
func _on_SummonOptionButton_action_highlighted(action: Action) -> void:
	update_for_summon(action)
