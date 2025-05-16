class_name ElementalStats
extends Resource
"""
Defines the elemental stats used by all characters: Magic, Resistance. The elemental
types are Earth, Fire, Water, Wind.
"""


# The elemental stats.
enum Type {MAGIC, RESISTANCE}
# The elemental types.
enum Element {EARTH, FIRE, WATER, WIND}

# Magic stat values
export(int, 0, 1000) var magic_earth_base = 0
export(int, 0, 1000) var magic_earth_growth = 0
export(int, 0, 1000) var magic_fire_base = 0
export(int, 0, 1000) var magic_fire_growth = 0
export(int, 0, 1000) var magic_water_base = 0
export(int, 0, 1000) var magic_water_growth = 0
export(int, 0, 1000) var magic_wind_base = 0
export(int, 0, 1000) var magic_wind_growth = 0
# Resistance stat values
export(int, 0, 1000) var res_earth_base = 0
export(int, 0, 1000) var res_earth_growth = 0
export(int, 0, 1000) var res_fire_base = 0
export(int, 0, 1000) var res_fire_growth = 0
export(int, 0, 1000) var res_water_base = 0
export(int, 0, 1000) var res_water_growth = 0
export(int, 0, 1000) var res_wind_base = 0
export(int, 0, 1000) var res_wind_growth = 0
