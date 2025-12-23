class_name DefensiveStats
extends Object
## Stores stat values that describe the defensive values of a character.
##
## Stores values for defense and resistance stats.


## The defense stat value.
var _defense: int = 0
## The resistance stat values for each core element.
var _res: Dictionary[Element.Core, int] = {
	Element.Core.EARTH: 0,
	Element.Core.FIRE: 0,
	Element.Core.WATER: 0,
	Element.Core.WIND: 0,
}


func _init(
	defense_value: int = 0,
	earth_res_value: int = 0,
	fire_res_value: int = 0,
	water_res_value: int = 0,
	wind_res_value: int = 0
) -> void:
	_defense = defense_value
	set_earth_res(earth_res_value)
	set_fire_res(fire_res_value)
	set_water_res(water_res_value)
	set_wind_res(wind_res_value)


## Gets the defense value.
func get_defense() -> int:
	return _defense


## Sets the defense value.
func set_defense(new_defense: int) -> void:
	_defense = new_defense


## Gets the resistance value for the earth element.
func get_earth_res() -> int:
	return get_res(Element.Core.EARTH as Element.Type)


## Sets the resistance value for the earth element.
func set_earth_res(value: int) -> void:
	set_core_res(Element.Core.EARTH, value)


## Gets the resistance value for the fire element.
func get_fire_res() -> int:
	return get_res(Element.Core.FIRE as Element.Type)


## Sets the resistance value for the fire element.
func set_fire_res(value: int) -> void:
	set_core_res(Element.Core.FIRE, value)


## Gets the resistance value for the water element.
func get_water_res() -> int:
	return get_res(Element.Core.WATER as Element.Type)


## Sets the resistance value for the water element.
func set_water_res(value: int) -> void:
	set_core_res(Element.Core.WATER, value)


## Gets the resistance value for the wind element.
func get_wind_res() -> int:
	return get_res(Element.Core.WIND as Element.Type)


## Sets the resistance value for the wind element.
func set_wind_res(value: int) -> void:
	set_core_res(Element.Core.WIND, value)


## Gets the resistance value for light element.
func get_light_res() -> int:
	var light_elems := ElementalAlignment.get_light_elements()
	return _get_alignment_sum(light_elems)


## Gets the resistance value for dark element.
func get_dark_res() -> int:
	var dark_elems := ElementalAlignment.get_dark_elements()
	return _get_alignment_sum(dark_elems)


## Gets the resistance value for a specified core element.
func get_res(element: Element.Type) -> int:
	match element:
		Element.Type.LIGHT:
			return get_light_res()
		Element.Type.DARK:
			return get_dark_res()
		_:
			return _res[element as Element.Core]


## Sets the resistance value for a specified core element.
func set_core_res(element: Element.Core, value: int) -> void:
	_res[element] = value


## Gets the total sum of the magic value of the specified elements. 
func _get_alignment_sum(alignment_elements: Array[Element.Core]) -> int:
	var total_value: int = 0
	for elem: Element.Core in alignment_elements:
		total_value += get_res(elem as Element.Type)
	return total_value
