class_name OptionData
extends Panel
## A panel that displays the details of an action.
##
## Able to show details for techniques and spells.


## The panel display for the range of the action.
@onready var _range_display: RangeDisplay = $RangeDisplay
## The label that describes the cost for the action, either cooldown or wisp.
@onready var _cost_label: Label = $Cost


## Creates a string that describes the cooldown for an action.
func _get_cooldown_text(cooldown: Cooldown) -> String:
	var text: String = "cooldown: {0}/{1}"
	return text.format(
			[
				cooldown.turn_count - cooldown.get_countdown(),
				cooldown.turn_count
			]
	)


## Creates a string that describes the wisp cost for an action.
func _get_cost_text(
	cost_summary: Dictionary[Element.Type, int],
	req_summary: Dictionary[Element.Type, int]
) -> String:
	var text: String = "wisp cost"
	for element in cost_summary:
		text += "\n{0} {1} -{2}-".format(
				[
					Element.Type.find_key(element),
					req_summary[element],
					cost_summary[element]
				]
		)
	for element in req_summary:
		if not cost_summary.has(element):
			text += "\n{0} {1}".format(
					[
						Element.Type.find_key(element),
						req_summary[element]
					]
			)
	return text


## Updates the data details to reflect the highlighted action.
func _on_ActionOptionButton_action_highlighted(action: Action) -> void:
	_range_display.update_action(action)
	var cooldown_node: Cooldown = action.get_node_or_null("Cooldown")
	if cooldown_node != null:
		_cost_label.text = _get_cooldown_text(cooldown_node)
		return
	var wisp_cost_node: WispCost = action.get_node_or_null("WispCost")
	if wisp_cost_node != null:
		_cost_label.text = _get_cost_text(
				wisp_cost_node.cost_summary,
				wisp_cost_node.req_summary
		)
		return


## Updates the data details to reflect the highlighted technique.
func _on_TechniqueOptionButton_action_highlighted(action: Action) -> void:
	_range_display.update_action(action)
	var cooldown_node: Cooldown = action.get_node_or_null("Cooldown")
	if cooldown_node != null:
		_cost_label.text = _get_cooldown_text(cooldown_node)
	else:
		printerr("Technique is missing a Cooldown node.")


## Updates the data details to reflect the highlighted spell.
func _on_SpellOptionButton_action_highlighted(action: Action) -> void:
	_range_display.update_action(action)
	var wisp_cost_node: WispCost = action.get_node_or_null("WispCost")
	if wisp_cost_node != null:
		_cost_label.text =  _get_cost_text(
				wisp_cost_node.cost_summary,
				wisp_cost_node.req_summary
		)
	else:
		printerr("Spell is missing a WispCost node.")


## Updates the data details to reflect the spawn action of the highlighted summon.
func _on_SummonOptionButton_summon_highlighted(
	action: Action,
	cost: Dictionary[Element.Type, int]
) -> void:
	_range_display.update_action(action)
	var wisp_cost_node: WispCost = action.get_node_or_null("WispCost")
	if wisp_cost_node != null:
		# You spend the cost as part of the requirement.
		_cost_label.text = _get_cost_text(cost, cost) + "\n"
	else:
		printerr("Spell is missing a WispCost node.")
	_cost_label.text += action.name
