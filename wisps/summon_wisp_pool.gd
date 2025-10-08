class_name SummonWispPool
extends WispPool
"""
Tracks the wisp states for a summon character.
"""


# Tracks which wisps are set to the summon, i.e. which wisps are available
# to be used for actions.
var pool: Dictionary = {
	Constants.Element.EARTH: [],
	Constants.Element.FIRE: [],
	Constants.Element.WATER: [],
	Constants.Element.WIND: [],
}


# Adds wisps to the specified element pool. The expectation is that wisp_ids
# will be an array of size 2 when adding wisps for LIGHT and DARK.
func add_wisps(wisp_ids: Array, element: int) -> void:
	match element:
		Constants.Element.LIGHT:
			var elems: Array = ElementalPolarity.get_light_elements()
			pool[elems[0]].append(wisp_ids[0])
			pool[elems[1]].append(wisp_ids[1])
			_active_count[elems[0]] += 1
			_active_count[elems[1]] += 1
		Constants.Element.DARK:
			var elems: Array = ElementalPolarity.get_dark_elements()
			pool[elems[0]].append(wisp_ids[0])
			pool[elems[1]].append(wisp_ids[1])
			_active_count[elems[0]] += 1
			_active_count[elems[1]] += 1
		_:
			pool[element].append_array(wisp_ids)
			_active_count[element] += wisp_ids.size()


# Gets the keys for the wisps that are used to pay for the specified element.
# Returns an empty array if no wisps are available for the given element.
func pay_for_element(element: int) -> Array:
	match element:
		Constants.Element.LIGHT:
			var elems: Array = ElementalPolarity.get_light_elements()
			_active_count[elems[0]] -= 1
			_active_count[elems[1]] -= 1
			return [pool[elems[0]].pop_front(), pool[elems[1]].pop_front()]
		Constants.Element.DARK:
			var elems: Array = ElementalPolarity.get_dark_elements()
			_active_count[elems[0]] -= 1
			_active_count[elems[1]] -= 1
			return [pool[elems[0]].pop_front(), pool[elems[1]].pop_front()]
		_:
			_active_count[element] -= 1
			return [pool[element].pop_front()]
