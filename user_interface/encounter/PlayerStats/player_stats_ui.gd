class_name PlayerStatsUI
extends Control
"""
The encounter scene UI element that displays a summary of a player character.
"""


@export var portrait_size: Vector2 = Vector2(0.0, 0.0)
@export var portrait_ref: NodePath = NodePath("")
@export var wisp_pool_ref: NodePath = NodePath("")

var _default_portrait: Texture2D = load(Constants.DEFAULT_ICON_PATH)

@onready var _player_portrait: TextureRect = get_node(portrait_ref)
@onready var _wisp_pool: WispPoolUI = get_node(wisp_pool_ref)
@onready var _health_bar: TextureProgressBar = $HealthBar
@onready var _health_label: Label = $HealthNumberLabel
@onready var _name_label: Label = $NameLabel


# Populate the display elements with the player stats.
func set_stats(player: PlayerCharacter) -> void:
	var cur_health: int = player.stats.get_stat(Stat.Type.CUR_HEALTH)
	var max_health: int = player.stats.get_stat(Stat.Type.MAX_HEALTH)
	_wisp_pool.set_wisp_pool(player.wisp_pool)
	_player_portrait.texture = _default_portrait
	_player_portrait.size = portrait_size
	_name_label.text = player.name
	set_hp(cur_health, max_health)
	player.stats.connect("health_changed", Callable(self, "_on_Character_hp_changed"))


# Sets the hp values of the summary.
func set_hp(cur_hp: int, max_hp: int) -> void:
	_health_label.text = "{0}/{1}".format([cur_hp, max_hp])
	_health_bar.max_value = max_hp
	_health_bar.value = cur_hp


# Updates the hp values when a character's health is changed.
func _on_Character_hp_changed(new_cur: int, new_max: int) -> void:
	set_hp(new_cur, new_max)
