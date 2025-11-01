class_name SummonWispPool
extends WispPool
## Tracks the wisp states for a summon character.


## Tracks which wisps are set to the summon, i.e. which wisps are available
## to be used for actions.
var pool: Dictionary = {
	Constants.CoreElement.EARTH: [],
	Constants.CoreElement.FIRE: [],
	Constants.CoreElement.WATER: [],
	Constants.CoreElement.WIND: [],
}


func _ready() -> void:
	for element in Constants.CoreElement.values():
		_active_count[element] = pool[element].size()


## Adds wisps to the specified element pool. The expectation is that wisp_ids
## will be an array with a size divisible by 2 when adding wisps for LIGHT and DARK.
func add_wisps(wisp_ids: Array, element: int) -> void:
	if element in Constants.PolarElement.keys():
		var elems: Array = (
			ElementalPolarity.get_light_elements()
			if element == Constants.PolarElement.LIGHT
			else ElementalPolarity.get_dark_elements()
		)
		var half_size: int = int(round(wisp_ids.size() / 2.0))
		for i in half_size:
			pool[elems[0]].append(wisp_ids[i])
			pool[elems[1]].append(wisp_ids[i + half_size])
		_active_count[elems[0]] += half_size
		_active_count[elems[1]] += half_size
		emit_signal("active_count_changed", elems[0])
		emit_signal("active_count_changed", elems[1])
		emit_signal("active_count_changed", element)
	elif element in Constants.CoreElement.keys():
		pool[element].append_array(wisp_ids)
		_active_count[element] += wisp_ids.size()
		emit_signal("active_count_changed", element)


## Gets the keys for the wisps that are used to pay for the specified element.
## These wisps are also removed from this pool. Returns an empty array if no
## wisps are available for the given element.
func pay_for_element(element: int, amount: int = 1) -> Array:
	var wisps_paid: Array = []
	if element in Constants.PolarElement.keys():
		var elems: Array = (
			ElementalPolarity.get_light_elements() 
			if element == Constants.PolarElement.LIGHT
			else ElementalPolarity.get_dark_elements()
		)
		_active_count[elems[0]] -= amount
		_active_count[elems[1]] -= amount
		emit_signal("active_count_changed", elems[0])
		emit_signal("active_count_changed", elems[1])
		emit_signal("active_count_changed", element)
		for i in amount:
			wisps_paid.append(pool[elems[0]].pop_front())
			wisps_paid.append(pool[elems[1]].pop_front())
	elif element in Constants.CoreElement.keys():
		_active_count[element] -= amount
		emit_signal("active_count_changed", element)
		for i in amount:
			wisps_paid.append(pool[element].pop_front())
	return wisps_paid
