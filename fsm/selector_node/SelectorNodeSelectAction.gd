extends SelectorState
"""
The logic for what happens when the Selector is in the 'SelectAction' state.
Manages 
"""


# The action to display the effect area for.
var action: Action = null


func enter(_msg: Dictionary = {}) -> void:
	action = _msg["action"]
	ErrorUtil.connect_signal(
		selector.collision_area,
		"area_entered",
		self,
		"_on_Selector_area_entered"
	)


# Called by the state machine before changing the active state. Use this 
# function to clean up the state.
func exit() -> void:
	selector.collision_area.disconnect("area_entered", self, "_on_Selector_area_entered")


# Handles input events
func handle_input(_event: InputEvent) -> void:
	"""
	TODO: Implement logic to handle controller input.
	"""
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


# Activate the selector for the hovered tile.
func _on_Selector_area_entered(map_tile: Area) -> void:
	if (
		map_tile.is_active() 
		and (
			map_tile.get_highlight_type() == HexHighlighter.Option.RANGE
			or map_tile.get_highlight_type() == HexHighlighter.Option.TARGET
			or map_tile.get_highlight_type() == HexHighlighter.Option.PLAYER
		)
	):
		selector.tile_hovered = map_tile
		
		if action.emit_from_center:
			action.emission_pt.translation = action.area_pt.translation
		else:
			action.emission_pt.translation = map_tile.translation
		
		if action.get_is_cardinal():
			if action.emit_from_center:
				action.rotate_to_point(map_tile.translation)
			else:
				action.rotate_to_point(action.area_pt.translation, true)
		
		selector.emit_signal("effect_selector_required", action.effect_range, false)
