class_name SummonData
extends Resource
## Stores data relevant to a character summon.
##
## Has references to various files and tracks data describing a summon. Records
## image data, stat multipliers, wisp requirements, and available actions.


## The default value for a stat multiplier. Corresponds to 100% of the
## summoner's stat.
const DEFAULT: float = 1.0
## The maximum value for a stat multiplier.
const MAX: float = 5.0
## The amount a stat multiplier can be adjusted by. Corresponds to 10%.
const STEP: float = 0.1
## The minimum possible number of wisps needed for a summon.
const MIN_WISP: int = 0
## The maximum possible number of wisps needed for a summon.
const MAX_WISP: int = 4

@export var name: String = ""
@export_group("Images")
@export var portrait: Texture2D = null
@export var battle_sprite: Texture2D = null
@export_group("Summoner Stat Multipliers")
@export_range(0, 10) var movement: int = 1
@export_range(DEFAULT, MAX, STEP) var attack: float = DEFAULT
@export_range(DEFAULT, MAX, STEP) var defense: float = DEFAULT
@export_subgroup("Magic", "magic_")
@export_range(DEFAULT, MAX, STEP) var magic_earth: float = DEFAULT
@export_range(DEFAULT, MAX, STEP) var magic_fire: float = DEFAULT
@export_range(DEFAULT, MAX, STEP) var magic_water: float = DEFAULT
@export_range(DEFAULT, MAX, STEP) var magic_wind: float = DEFAULT
@export_subgroup("Resistance", "res_")
@export_range(DEFAULT, MAX, STEP) var res_earth: float = DEFAULT
@export_range(DEFAULT, MAX, STEP) var res_fire: float = DEFAULT
@export_range(DEFAULT, MAX, STEP) var res_water: float = DEFAULT
@export_range(DEFAULT, MAX, STEP) var res_wind: float = DEFAULT
@export_group("Wisp Requirement and Cost")
@export_range(MIN_WISP, MAX_WISP) var earth_req: int = MIN_WISP
@export_range(MIN_WISP, MAX_WISP) var fire_req: int = MIN_WISP
@export_range(MIN_WISP, MAX_WISP) var water_req: int = MIN_WISP
@export_range(MIN_WISP, MAX_WISP) var wind_req: int = MIN_WISP
@export_range(MIN_WISP, MAX_WISP) var light_req: int = MIN_WISP
@export_range(MIN_WISP, MAX_WISP) var dark_req: int = MIN_WISP
@export_group("Actions")
@export var summon_action: ActionStats = null
@export var turn_actions: Array[SpellStats] = []


## Returns the multiplier value for the given stat.
func multiplier_for_stat(stat: Stat.Type) -> float:
	match stat:
		Stat.Type.ATTACK:
			return attack
		Stat.Type.DEFENSE:
			return defense
		Stat.Type.MOVEMENT:
			return movement
		Stat.Type.MAGIC_EARTH:
			return magic_earth
		Stat.Type.MAGIC_FIRE:
			return magic_fire
		Stat.Type.MAGIC_WATER:
			return magic_water
		Stat.Type.MAGIC_WIND:
			return magic_wind
		Stat.Type.MAGIC_LIGHT:
			var light_elems: Array = Stat.get_light_aligned_magic()
			var mult_1: float = multiplier_for_stat(light_elems[0])
			var mult_2: float = multiplier_for_stat(light_elems[1])
			return mult_1 + mult_2
		Stat.Type.MAGIC_DARK:
			var dark_elems: Array = Stat.get_dark_aligned_magic()
			var mult_1: float = multiplier_for_stat(dark_elems[0])
			var mult_2: float = multiplier_for_stat(dark_elems[1])
			return mult_1 + mult_2
		Stat.Type.RES_EARTH:
			return res_earth
		Stat.Type.RES_FIRE:
			return res_fire
		Stat.Type.RES_WATER:
			return res_water
		Stat.Type.RES_WIND:
			return res_wind
		Stat.Type.RES_LIGHT:
			var light_elems: Array = Stat.get_light_aligned_res()
			var mult_1: float = multiplier_for_stat(light_elems[0])
			var mult_2: float = multiplier_for_stat(light_elems[1])
			return mult_1 + mult_2
		Stat.Type.RES_DARK:
			var dark_elems: Array = Stat.get_dark_aligned_res()
			var mult_1: float = multiplier_for_stat(dark_elems[0])
			var mult_2: float = multiplier_for_stat(dark_elems[1])
			return mult_1 + mult_2
		_:
			return DEFAULT


## Checks if the provided wisp pool matches the requirements for this summon.
func wisp_pool_meets_requirements(pool: WispPool) -> bool:
	return false


## Checks if the provided core element counts match the requirements for this
## summon.
func core_requirements_met(counts: Dictionary[Element.Core, int]) -> bool:
	return false
