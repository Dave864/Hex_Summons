class_name ActivePlayerStats
extends Control
"""
The encounter scene UI element that displays a summary of the stats of the
currently active player character.
"""


onready var _player_portrait: TextureRect = $PlayerWispPool/PlayerPortrait
onready var _health_bar: TextureProgress = $HealthBar
onready var _health_label: Label = $HealthNumberLabel
onready var _name_label: Label = $NameLabel
onready var _wisp_pool: PlayerWispPoolUI = $PlayerWispPool


# Populate the display elements with the player stats.
func set_stats(player: PlayerCharacter) -> void:
	var cur_health: int = player.stats.get_stat(Stat.Type.CUR_HEALTH)
	var max_health: int = player.stats.get_stat(Stat.Type.MAX_HEALTH)
#	_wisp_pool.set_wisp_pool(player.wisp_pool)
	_health_bar.max_value = max_health
	_health_bar.value = cur_health
	_health_label.text = "{0}/{1}".format([cur_health, max_health])
	_name_label.text = player.name
