class_name Summon
extends Area3D
## Manages the creation and using of summons.
##
## Tracks which summons are selectable in an encounter scene. Represents an active
## summon when the user executes the "Summon" action. Handles the swapping of
## summon details. The summon wisp pool is handled by the WispController.


## The character that conjured the active summon.
var summoner: PlayerCharacter = null
## The summons that are able to be conjured by the current player party in the
## encounter.
var available_summons: Dictionary = {}

## The sprite used for the summon character in the encounter world.
@onready var character_sprite: EncounterSprite = $EncounterSprite
## The node tracking the map coordinate of the character.
@onready var map_coordinate: MapCoordinate = $MapCoordinate
## The collision area used to interact with character actions.
@onready var hit_box: Area3D = $HitBox
## Creates curves for movement paths.
@onready var hm_move_path: HexMapMovementCurve = HexMapMovementCurve.new()


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


## Sets the selected summon to be active and places them at the specified map
## coordinate.
func load_summon(summon_id: int, spawn_coordinate: MapCoordinate) -> void:
	pass


## Loads the data for the summons that are able to be conjured based on the current
## wisps available to the party.
func _cache_available_summons() -> void:
	pass
