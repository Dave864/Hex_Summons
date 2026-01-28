class_name UserCharacterStatsUI
extends Control
## The encounter scene UI element that displays a summary of a character,
## usually player or summon.


@export var portrait_size: Vector2 = Vector2(0.0, 0.0)
@export var character_portrait: TextureRect = null
@export var wisp_pool_ui: WispPoolUI = null

var _default_portrait: Texture2D = load(Constants.DEFAULT_ICON_PATH)

@onready var _health_bar: TextureProgressBar = $HealthBar
@onready var _health_label: Label = $HealthNumberLabel
@onready var _name_label: Label = $NameLabel


## Populate the display elements with the player character stats.
func set_player_stats(player: PlayerCharacter) -> void:
	wisp_pool_ui.set_wisp_pool(player.wisp_pool)
	_set_character_stats(player)
	_name_label.text = player.name
	if (
		not player.stats.is_connected(
				"health_changed",
				Callable(self, "_on_Character_hp_changed")
		)
	):
		player.stats.connect(
				"health_changed",
				Callable(self, "_on_Character_hp_changed")
		)


## Populate the display elements with the summon character stats.
func set_summon_stats(summon: Summon) -> void:
	wisp_pool_ui.set_wisp_pool(summon.summon_wisp_pool)
	_set_character_stats(summon)
	_name_label.text = summon.get_active_summon_name()


## Sets the hp values of the summary.
func set_hp(cur_hp: int, max_hp: int) -> void:
	_health_label.text = "{0}/{1}".format([cur_hp, max_hp])
	_health_bar.max_value = max_hp
	_health_bar.value = cur_hp


## Populate the display elements with generic character stats.
func _set_character_stats(character: Character) -> void:
	var cur_health: int = character.stats.get_stat(Stat.Type.CUR_HEALTH)
	var max_health: int = character.stats.get_stat(Stat.Type.MAX_HEALTH)
	set_hp(cur_health, max_health)
	character_portrait.texture = (
		_default_portrait if character.battle_portrait == null
		else character.battle_portrait
	)
	character_portrait.size = portrait_size


## Updates the hp values when a character's health is changed.
func _on_Character_hp_changed(new_cur: int, new_max: int) -> void:
	set_hp(new_cur, new_max)
