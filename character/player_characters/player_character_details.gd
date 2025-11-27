class_name PlayerCharacterDetails
extends Resource
## Stores details for a player character.


## The name of the player character.
@export var player_name: String = ""
## The image used to represent the player in the initiative tracker.
@export var encounter_initiative_portrait: Texture2D = null
## The image used to represent the player in the active player portrait.
@export var encounter_active_portrait: Texture2D = null
## The image used to represent the player in the map.
@export var encounter_battle_sprite: Texture2D = null
