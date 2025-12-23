class_name OffensiveStats
extends Object
## Stores stat values that describe the offensive values of a character.
##
## Stores values for attack and magic stats.


## The attack stat value.
var _attack: int = 0
## The magic stat values for each core element.
var _magic: Dictionary[Element.Core, int] = {
	Element.Core.EARTH: 0,
	Element.Core.FIRE: 0,
	Element.Core.WATER: 0,
	Element.Core.WIND: 0,
}


func _init(
	attack_value: int = 0,
	earth_magic_value: int = 0,
	fire_magic_value: int = 0,
	water_magic_value: int = 0,
	wind_magic_value: int = 0
) -> void:
	_attack = attack_value
	set_earth_magic(earth_magic_value)
	set_fire_magic(fire_magic_value)
	set_water_magic(water_magic_value)
	set_wind_magic(wind_magic_value)


## Gets the attack value.
func get_attack() -> int:
	return _attack


## Sets the attack value.
func set_attack(new_attack: int) -> void:
	_attack = new_attack


## Gets the magic value for the earth element.
func get_earth_magic() -> int:
	return get_magic(Element.Core.EARTH as Element.Type)


## Sets the magic value for the earth element.
func set_earth_magic(value: int) -> void:
	set_core_magic(Element.Core.EARTH, value)


## Gets the magic value for the fire element.
func get_fire_magic() -> int:
	return get_magic(Element.Core.FIRE as Element.Type)


## Sets the magic value for the fire element.
func set_fire_magic(value: int) -> void:
	set_core_magic(Element.Core.FIRE, value)


## Gets the magic value for the water element.
func get_water_magic() -> int:
	return get_magic(Element.Core.WATER as Element.Type)


## Sets the magic value for the water element.
func set_water_magic(value: int) -> void:
	set_core_magic(Element.Core.WATER, value)


## Gets the magic value for the wind element.
func get_wind_magic() -> int:
	return get_magic(Element.Core.WIND as Element.Type)


## Sets the magic value for the wind element.
func set_wind_magic(value: int) -> void:
	set_core_magic(Element.Core.WIND, value)


## Gets the magic value for light element.
func get_light_magic() -> int:
	var light_elems := ElementalAlignment.get_light_elements()
	return _get_alignment_sum(light_elems)


## Gets the magic value for dark element.
func get_dark_magic() -> int:
	var dark_elems := ElementalAlignment.get_dark_elements()
	return _get_alignment_sum(dark_elems)


## Gets the magic value for a specified element.
func get_magic(element: Element.Type) -> int:
	match element:
		Element.Type.LIGHT:
			return get_light_magic()
		Element.Type.DARK:
			return get_dark_magic()
		_:
			return _magic[element as Element.Core]


## Sets the magic value for a specified core element.
func set_core_magic(element: Element.Core, value: int) -> void:
	_magic[element] = value


## Gets the total sum of the magic value of the specified elements. 
func _get_alignment_sum(alignment_elements: Array[Element.Core]) -> int:
	var total_value: int = 0
	for elem: Element.Core in alignment_elements:
		total_value += get_magic(elem as Element.Type)
	return total_value
