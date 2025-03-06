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
	_health_label.text = "%d/%d" % [player.stats.get_cur_health(), player.stats.get_max_health()]
	_name_label.text = player.name


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
