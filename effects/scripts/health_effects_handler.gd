class_name HealthEffectsHandler
extends Node
"""
Tracks the effects that modify the health stat. Health can be immediately changed
or changed over time.
"""


# Buses that keep track of the effects that affect the managed stat.
var _flat_change_bus: EffectBus
var _percentage_change_bus: EffectBus


# Called when the node enters the scene tree for the first time.
func _ready():
	_flat_change_bus = EffectBus.new(Stat.Type.CUR_HEALTH)
	_percentage_change_bus = EffectBus.new(Stat.Type.CUR_HEALTH)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


# Connects the effects of an action to this manager.
func _on_HitBox_area_entered(_action: Area) -> void:
	# Go through all of the effects associated with this action
	# Get the ones that apply to health.
	# Apply resistance to all effects that require it
	# Update the modifier value
	pass
