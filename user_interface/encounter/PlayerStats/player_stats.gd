class_name PlayerStats
extends Control
"""
The encounter scene UI element that displays a summary of a player character.
"""


export var portrait_size: Vector2 = Vector2(0.0, 0.0)
export var portrait_ref: NodePath = NodePath("")
export var wisp_pool_ref: NodePath = NodePath("")

var _default_portrait: Texture = preload("res://art/icon.png")

onready var _player_portrait: TextureRect = get_node(portrait_ref)
onready var _wisp_pool: WispPoolUI = get_node(wisp_pool_ref)
onready var _health_bar: TextureProgress = $HealthBar
onready var _health_label: Label = $HealthNumberLabel
onready var _name_label: Label = $NameLabel


# Populate the display elements with the player stats.
func set_stats(player: PlayerCharacter) -> void:
	var cur_health: int = player.stats.get_stat(Stat.Type.CUR_HEALTH)
	var max_health: int = player.stats.get_stat(Stat.Type.MAX_HEALTH)
	"""
	TODO: Update logic to load the player portrait if available. Update logic
	to set the player wisp pool.
	"""
#	_wisp_pool.set_wisp_pool(player.wisp_pool)
	_player_portrait.texture = _default_portrait
	_player_portrait.rect_size = portrait_size
	_health_bar.max_value = max_health
	_health_bar.value = cur_health
	_health_label.text = "{0}/{1}".format([cur_health, max_health])
	_name_label.text = player.name
