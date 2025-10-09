class_name SummonWispPoolUI
extends WispPoolUI
"""
Represents the wisp pool for the summon pool.
"""


# Virtual function. Initializes the wisp pool reference.
func _set_wisp_pool() -> void:
	pool = $SummonWispPool
