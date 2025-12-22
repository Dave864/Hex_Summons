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
	return get_magic(Element.Core.EARTH)


## Sets the magic value for the earth element.
func set_earth_magic(value: int) -> void:
	set_magic(Element.Core.EARTH, value)


## Gets the magic value for the fire element.
func get_fire_magic() -> int:
	return get_magic(Element.Core.FIRE)


## Sets the magic value for the fire element.
func set_fire_magic(value: int) -> void:
	set_magic(Element.Core.FIRE, value)


## Gets the magic value for the water element.
func get_water_magic() -> int:
	return get_magic(Element.Core.WATER)


## Sets the magic value for the water element.
func set_water_magic(value: int) -> void:
	set_magic(Element.Core.WATER, value)


## Gets the magic value for the wind element.
func get_wind_magic() -> int:
	return get_magic(Element.Core.WIND)


## Sets the magic value for the wind element.
func set_wind_magic(value: int) -> void:
	set_magic(Element.Core.WIND, value)


## Gets the magic value for a specified core element.
func get_magic(element: Element.Core) -> int:
	return _magic[element]


## Sets the magic value for a specified core element.
func set_magic(element: Element.Core, value: int) -> void:
	_magic[element] = value
