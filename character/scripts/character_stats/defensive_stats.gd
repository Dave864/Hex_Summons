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
	return get_res(Element.Core.EARTH)


## Sets the resistance value for the earth element.
func set_earth_res(value: int) -> void:
	set_res(Element.Core.EARTH, value)


## Gets the resistance value for the fire element.
func get_fire_res() -> int:
	return get_res(Element.Core.FIRE)


## Sets the resistance value for the fire element.
func set_fire_res(value: int) -> void:
	set_res(Element.Core.FIRE, value)


## Gets the resistance value for the water element.
func get_water_res() -> int:
	return get_res(Element.Core.WATER)


## Sets the resistance value for the water element.
func set_water_res(value: int) -> void:
	set_res(Element.Core.WATER, value)


## Gets the resistance value for the wind element.
func get_wind_res() -> int:
	return get_res(Element.Core.WIND)


## Sets the resistance value for the wind element.
func set_wind_res(value: int) -> void:
	set_res(Element.Core.WIND, value)


## Gets the resistance value for a specified core element.
func get_res(element: Element.Core) -> int:
	return _res[element]


## Sets the resistance value for a specified core element.
func set_res(element: Element.Core, value: int) -> void:
	_res[element] = value
