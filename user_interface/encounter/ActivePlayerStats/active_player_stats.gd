class_name ActivePlayerStats
extends Control
"""
The encounter scene UI element that displays a summary of the stats of the
currently active player character.
"""


onready var _player_portrait: TextureRect = $PlayerWispPool/PlayerPortrait
onready var _health_label: Label = $HealthNumberLabel
onready var _name_label: Label = $NameLabel
onready var _wisp_pool: PlayerWispPoolUI = $PlayerWispPool


# Populate the display elements with the player stats.
func set_stats(player: PlayerCharacter) -> void:
#	_wisp_pool.set_wisp_pool(player.wisp_pool)
	_health_label.text = (
			"%d/%d" % \
			[
				player.stats.get_stat(Stat.Type.CUR_HEALTH),
				player.stats.get_stat(Stat.Type.MAX_HEALTH)
			]
	)
	_name_label.text = player.name
