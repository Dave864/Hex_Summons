class_name ActivePlayerStats
extends PanelContainer
"""
The encounter scene UI element that displays a summary of the stats of the
currently active player character.
"""


onready var _player_icon = $VBoxContainer/Icon
onready var _health_label = $VBoxContainer/Health
onready var _name_label = $VBoxContainer/Name


# Populate the display elements with the player stats.
func set_stats(player: PlayerCharacter) -> void:
	_check_for_required_parameters()
	_health_label.text = (
			"%d/%d" % \
			[
				player.stats.get_stat(Stat.Type.CUR_HEALTH),
				player.stats.get_stat(Stat.Type.MAX_HEALTH)
			]
	)
	_name_label.text = player.name


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


# Checks that all required parameters are set.
func _check_for_required_parameters() -> void:
	assert(
			_player_icon is TextureRect,
			"_player_icon of ActivePlayerStats is not a TextureRect."
	)
	assert(
			_health_label is Label,
			"_health_label of ActivePlayerStats is not a Label."
	)
	assert(
			_name_label is Label,
			"_name_label of ActivePlayerStats is not a Label."
	)
