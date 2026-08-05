class_name UserCharacterStatsUI
extends Control
## The encounter scene UI element that displays a summary of a character,
## usually player or summon.


@export var character_portrait: TextureRect = null
@export var wisp_pool_ui: WispPoolUI = null
@export var health_bar: TextureProgressBar = null
@export var health_label: Label = null
@export var name_label: Label = null

var _default_portrait: Texture2D = load(Constants.DEFAULT_ICON_PATH)
var _portrait_size: Vector2 = Vector2(0.0, 0.0)


func _ready() -> void:
	if character_portrait != null:
		_portrait_size = character_portrait.size


## Populate the display elements with the player character stats.
func set_player_stats(player: PlayerCharacter) -> void:
	wisp_pool_ui.set_wisp_pool(player.wisp_pool)
	_set_character_stats(player)
	name_label.text = player.name
	if not player.stats.health_changed.is_connected(_on_Character_hp_changed):
		player.stats.health_changed.connect(_on_Character_hp_changed)


## Populate the display elements with the summon character stats.
func set_summon_stats(summon: Summon) -> void:
	wisp_pool_ui.set_wisp_pool(summon.summon_wisp_pool)
	_set_character_stats(summon)
	name_label.text = summon.get_active_summon_name()


## Sets the hp values of the summary.
func set_hp(cur_hp: int, max_hp: int) -> void:
	health_label.text = "{0}/{1}".format([cur_hp, max_hp])
	health_bar.value = float(cur_hp) / float(max_hp) * 100


## Populate the display elements with generic character stats.
func _set_character_stats(character: Character) -> void:
	var cur_health: int = character.stats.get_stat(Stat.Type.CUR_HEALTH)
	var max_health: int = character.stats.get_stat(Stat.Type.MAX_HEALTH)
	set_hp(cur_health, max_health)
	character_portrait.texture = (
		_default_portrait if character.battle_portrait == null
		else character.battle_portrait
	)
	character_portrait.size = _portrait_size


## Updates the hp values when a character's health is changed.
func _on_Character_hp_changed(new_cur: int, new_max: int) -> void:
	set_hp(new_cur, new_max)
