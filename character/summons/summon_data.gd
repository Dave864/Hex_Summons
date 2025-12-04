class_name SummonData
extends Resource
## Stores data relevant to a character summon.
##
## Has references to various files and tracks data describing a summon. Records
## image data, stat multipliers, wisp requirements, and available actions.


@export var name: String = ""
@export_group("Images")
@export var portrait: Texture2D = null
@export var battle_sprite: Texture2D = null
@export_group("Summoner Stat Multipliers")
@export_range(0, 10) var movement: int = 1
@export_range(0.0, 5.0, 0.1) var attack: float = 1.0
@export_range(0.0, 5.0, 0.1) var defense: float = 1.0
@export_subgroup("Magic", "magic_")
@export_range(0.0, 5.0, 0.1) var magic_earth: float = 1.0
@export_range(0.0, 5.0, 0.1) var magic_fire: float = 1.0
@export_range(0.0, 5.0, 0.1) var magic_water: float = 1.0
@export_range(0.0, 5.0, 0.1) var magic_wind: float = 1.0
@export_subgroup("Resistance", "res_")
@export_range(0.0, 5.0, 0.1) var res_earth: float = 1.0
@export_range(0.0, 5.0, 0.1) var res_fire: float = 1.0
@export_range(0.0, 5.0, 0.1) var res_water: float = 1.0
@export_range(0.0, 5.0, 0.1) var res_wind: float = 1.0
@export_group("Wisp Requirement and Cost")
@export_range(0, 4) var earth_req: int = 0
@export_range(0, 4) var fire_req: int = 0
@export_range(0, 4) var water_req: int = 0
@export_range(0, 4) var wind_req: int = 0
@export_range(0, 4) var light_req: int = 0
@export_range(0, 4) var dark_req: int = 0
@export_group("Actions")
@export var summon_action: ActionStats = null
@export var turn_actions: Array[SpellStats] = []
