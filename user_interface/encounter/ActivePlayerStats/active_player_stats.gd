class_name ActivePlayerStats
extends Control
"""
The encounter scene UI element that displays a summary of the stats of the
currently active player character.
"""


const PORTRAIT_SIZE: Vector2 = Vector2(46, 46)

var _default_portrait: Texture = preload("res://art/icon.png")

onready var _player_portrait: TextureRect = $PlayerWispPool/PlayerPortrait
onready var _health_bar: TextureProgress = $HealthBar
onready var _health_label: Label = $HealthNumberLabel
onready var _name_label: Label = $NameLabel
onready var _wisp_pool: PlayerWispPoolUI = $PlayerWispPool


# Populate the display elements with the player stats.
func set_stats(player: PlayerCharacter) -> void:
	var cur_health: int = player.stats.get_stat(Stat.Type.CUR_HEALTH)
	var max_health: int = player.stats.get_stat(Stat.Type.MAX_HEALTH)
	"""
	TODO: Update logic to load the active portrait if available. Update logic
	to set the player wisp pool.
	"""
#	_wisp_pool.set_wisp_pool(player.wisp_pool)
	_player_portrait.texture = _default_portrait
	_player_portrait.rect_size = PORTRAIT_SIZE
	_health_bar.max_value = max_health
	_health_bar.value = cur_health
	_health_label.text = "{0}/{1}".format([cur_health, max_health])
	_name_label.text = player.name
