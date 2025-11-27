class_name DamageEffect
extends Effect
## Defines the core details of a damage effect.


## Called when the node enters the scene tree for the first time.
func _ready():
	_aspects = get_children()
	_check_for_required_parameters()
	_check_for_required_damage_parameters()


## Check that all required parameters for damage are set.
func _check_for_required_damage_parameters() -> void:
	assert(
			_aspects.size() == 1,
			"More than one EffectAspect has been assigned to Damage."
	)
