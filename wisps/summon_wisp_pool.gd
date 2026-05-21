class_name SummonWispPool
extends WispPool
## Tracks the wisp states for a summon character.


## Tracks which wisps are set to the summon, i.e. which wisps are available
## to be used for actions.
var pool: Dictionary[Element.Core, Array] = {
	Element.Core.EARTH: [],
	Element.Core.FIRE: [],
	Element.Core.WATER: [],
	Element.Core.WIND: [],
}


func _ready() -> void:
	for element: int in Element.Core.values():
		_active_count[element] = pool[element].size()


## Adds wisps to the specified element pool. The expectation is that wisp_ids
## will be an array with a size divisible by 2 when adding wisps for LIGHT and DARK.
func add_wisps(wisp_names: Array[String], element: Element.Type) -> void:
	if element in Element.Alignment.values():
		var elems: Array[Element.Core] = (
			ElementalAlignment.get_light_elements()
			if element == Element.Alignment.LIGHT
			else ElementalAlignment.get_dark_elements()
		)
		var half_size: int = int(round(wisp_names.size() / 2.0))
		for i: int in half_size:
			pool[elems[0]].append(wisp_names[i])
			pool[elems[1]].append(wisp_names[i + half_size])
		_active_count[elems[0]] += half_size
		_active_count[elems[1]] += half_size
		emit_signal("active_count_changed", elems[0])
		emit_signal("active_count_changed", elems[1])
		emit_signal("active_count_changed", element)
	elif element in Element.Core.values():
		pool[element].append_array(wisp_names)
		_active_count[element] += wisp_names.size()
		emit_signal("active_count_changed", element)


## Removes wisps from whatever element pool they are in. If any provided names
## are not in any pool, nothing happens for that name.
func remove_wisps(wisp_names: PackedStringArray) -> void:
	for wisp: String in wisp_names:
		for element: Element.Core in pool.keys():
			var element_wisps: PackedStringArray = pool[element]
			if element_wisps.has(wisp):
				_active_count[element] -= 1
				emit_signal("active_count_changed", element)
				element_wisps.erase(wisp)


## Gets the keys for the wisps that are used to pay for the specified element.
## These wisps are also removed from this pool. Returns an empty array if no
## wisps are available for the given element.
func pay_for_element(element: Element.Type, amount: int = 1) -> Array[String]:
	var wisps_paid: Array[String] = []
	if element in Element.Alignment.values():
		var elems: Array[Element.Core] = (
			ElementalAlignment.get_light_elements()
			if element == Element.Alignment.LIGHT
			else ElementalAlignment.get_dark_elements()
		)
		_active_count[elems[0]] -= amount
		_active_count[elems[1]] -= amount
		emit_signal("active_count_changed", elems[0])
		emit_signal("active_count_changed", elems[1])
		emit_signal("active_count_changed", element)
		wisps_paid.resize(amount * 2)
		for i: int in amount:
			wisps_paid[i] = pool[elems[0]].pop_front()
			wisps_paid[amount + i] = pool[elems[1]].pop_front()
	elif element in Element.Core.values():
		_active_count[element] -= amount
		emit_signal("active_count_changed", element)
		wisps_paid.resize(amount)
		for i: int in amount:
			wisps_paid[i] = pool[element].pop_front()
	return wisps_paid
