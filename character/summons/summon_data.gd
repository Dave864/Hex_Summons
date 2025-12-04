class_name SummonData
extends Resource
## Stores data relevant to a character summon.
##
## Has references to various files and tracks data describing a summon. Records
## image data, stat multipliers, wisp requirements, and available actions.


@export_group("Images")
@export var portrait: Texture2D = null
@export var battle_sprite: Texture2D = null
@export_group("Wisp Requirement and Cost")
@export var earth_req = 0 # (int, 0, 4)
@export var fire_req = 0 # (int, 0, 4)
@export var water_req = 0 # (int, 0, 4)
@export var wind_req = 0 # (int, 0, 4)
@export var light_req = 0 # (int, 0, 4)
@export var dark_req = 0 # (int, 0, 4)
@export_group("Actions")
@export var summon_action: ActionStats = null
@export var turn_actions: Array[SpellStats] = []
