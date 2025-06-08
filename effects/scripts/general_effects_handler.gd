class_name GeneralEffectsHandler
extends Node
"""
Tracks the effects that modify the specified stat. This is used for attack,
defense, agility, magic, and resistance which follow the same rules for being changed.
These stats can be raised or lowered by a flat amount or by a percentage. Flat
changes are all applied first. The total percentage changes are combined into a
single multiplier that is then applied after the flat values.
"""


# Represents the stats that can be managed.
enum stat {
	ATTACK,
	DEFENSE,
	AGILITY,
	MAGIC_EARTH,
	MAGIC_FIRE,
	MAGIC_WATER,
	MAGIC_WIND,
	MAGIC_LIGHT,
	MAGIC_DARK,
	RES_EARTH,
	RES_FIRE,
	RES_WATER,
	RES_WIND,
	RES_LIGHT,
	RES_DARK,
}

# Maps the stat to the respective enum value in the Stat resource.
var _global_reference: Dictionary = {
	stat.ATTACK: Stat.Type.ATTACK,
	stat.DEFENSE: Stat.Type.DEFENSE,
	stat.AGILITY: Stat.Type.AGILITY,
	stat.MAGIC_EARTH: Stat.Type.MAGIC_EARTH,
	stat.MAGIC_FIRE: Stat.Type.MAGIC_FIRE,
	stat.MAGIC_WATER: Stat.Type.MAGIC_WATER,
	stat.MAGIC_WIND: Stat.Type.MAGIC_WIND,
	stat.MAGIC_LIGHT: Stat.Type.MAGIC_LIGHT,
	stat.MAGIC_DARK: Stat.Type.MAGIC_DARK,
	stat.RES_EARTH: Stat.Type.RES_EARTH,
	stat.RES_FIRE: Stat.Type.RES_FIRE,
	stat.RES_WATER: Stat.Type.RES_WATER,
	stat.RES_WIND: Stat.Type.RES_WIND,
	stat.RES_LIGHT: Stat.Type.RES_LIGHT,
	stat.RES_DARK: Stat.Type.RES_DARK,
}

# The stat that is represented.
export(stat) var target_stat = stat.ATTACK

var _base_value: int setget set_base_value
# Buses that keep track of the effects that affect the managed stat.
var _flat_change_bus: EffectBus
var _percentage_change_bus: EffectBus

# Setter for the base value.
func set_base_value(new_base: int) -> void:
	_base_value = new_base


# Gets the current value of this stat, applying all of the modifiers.
func get_cur_value() -> int:
	return 0


# Updates the duration for all effects.
func progress_duration(turn_count: int = 1) -> void:
	_flat_change_bus.progress_duration(turn_count)
	_percentage_change_bus.progress_duration(turn_count)


# Determines the final value of the affected stat after applying all of the effects.
# Uses the provided character stats as reference. Character stats are updated.
func process_effects(character_stats: CharacterStats) -> void:
	var final_value: int = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	_flat_change_bus = EffectBus.new(_global_reference[stat])
	_percentage_change_bus = EffectBus.new(_global_reference[stat])


# Connects the effects of an action to this manager.
func _on_HitBox_area_entered(_action: Area) -> void:
	# Go through all of the effects associated with this action
	# Get the ones that apply to the specified stat.
	# Apply resistance to all effects that require it
	# Update the modifier value
	pass
