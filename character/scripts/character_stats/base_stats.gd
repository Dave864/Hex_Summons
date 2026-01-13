class_name BaseStats
extends Resource
## Defines the stat values for a character. Includes base value and growth rate.


@export_group("Core Stats")
@export_subgroup("Base Values")
@export_range(0, 1000) var health_base: int = 1
@export_range(0, 1000) var attack_base: int = 1
@export_range(0, 1000) var defense_base: int = 1
@export_range(0, 1000) var agility_base: int = 1
@export_range(1, 20) var movement: int = 1
@export_subgroup("Growth Values")
@export_range(0, 1000) var health_growth: int = 1
@export_range(0, 1000) var attack_growth: int = 1
@export_range(0, 1000) var defense_growth: int = 1
@export_range(0, 1000) var agility_growth: int = 1

@export_group("Magic Stats", "magic_")
@export_subgroup("Base Values")
@export_range(0, 1000) var magic_earth_base: int = 0
@export_range(0, 1000) var magic_fire_base: int = 0
@export_range(0, 1000) var magic_water_base: int = 0
@export_range(0, 1000) var magic_wind_base: int = 0
@export_subgroup("Growth Values")
@export_range(0, 1000) var magic_earth_growth = 0
@export_range(0, 1000) var magic_fire_growth = 0
@export_range(0, 1000) var magic_water_growth = 0
@export_range(0, 1000) var magic_wind_growth = 0

@export_group("Resistance Stats", "res_")
@export_subgroup("Base Values")
@export_range(0, 1000) var res_earth_base: int = 0
@export_range(0, 1000) var res_fire_base: int = 0
@export_range(0, 1000) var res_water_base: int = 0
@export_range(0, 1000) var res_wind_base: int = 0
@export_subgroup("Growth Values")
@export_range(0, 1000) var res_earth_growth: int = 0
@export_range(0, 1000) var res_fire_growth: int = 0
@export_range(0, 1000) var res_water_growth: int = 0
@export_range(0, 1000) var res_wind_growth: int = 0
