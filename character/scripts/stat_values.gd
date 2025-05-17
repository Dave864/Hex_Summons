class_name StatValues
extends Resource
"""
Defines the stat values for a character. Includes base value and growth rate.
"""


# Base stat values
export(int, 0, 1000) var health_base = 1
export(int, 0, 1000) var health_growth = 1
export(int, 0, 1000) var attack_base = 1
export(int, 0, 1000) var attack_growth = 1
export(int, 0, 1000) var defense_base = 1
export(int, 0, 1000) var defense_growth = 1
export(int, 0, 1000) var agility_base = 1
export(int, 0, 1000) var agility_growth = 1
export(int, 1, 20) var movement = 1
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
