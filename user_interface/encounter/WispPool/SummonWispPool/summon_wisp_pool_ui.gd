class_name SummonWispPoolUI
extends WispPoolUI
## Represents the wisp pool for the summon pool.


## Called when the node enters the scene tree for the first time.
func _ready():
	ElementalAlignment.connect(
			"alignment_changed",
			Callable(self, "_on_ElementalAlignment_alignment_changed")
	)
	set_wisp_pool(WispController.summon_pool)
	_set_icons()
	_set_labels_on_ready()
