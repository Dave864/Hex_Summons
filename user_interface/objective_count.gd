class_name ObjectiveCount
extends Label
## Label that lists the progression count towards an objective.
##
## Changes the font color to indicate that the objective is complete. Is able to
## cap the count at the objective limit.


## The format of the label text.
const LABEL_FORMAT := "{0}/{1}"

## The enemy count to reflect.
@export_enum(
	ObjectiveTracker.TRACKED_ENEMIES[0],
	ObjectiveTracker.TRACKED_ENEMIES[1],
	ObjectiveTracker.TRACKED_ENEMIES[2]
) var tracked_enemy := ObjectiveTracker.TRACKED_ENEMIES[0]
## The color used to indicate that the objective is complete.
@export var color_complete := Color.AQUA
## Flag that indicates the kill count is capped.
@export var cap_at_objective := true


## Sets the label to reflect the objective progress.
func _ready() -> void:
	if label_settings == null:
		label_settings = LabelSettings.new()
	if ObjectiveTracker.kill_objective_met(tracked_enemy):
		label_settings.font_color = color_complete
	var progress_count: int = ObjectiveTracker.kill_objectives[tracked_enemy][1]
	var objective_count: int = ObjectiveTracker.kill_objectives[tracked_enemy][0]
	if cap_at_objective:
		progress_count = clampi(progress_count, 0, objective_count)
	text = LABEL_FORMAT.format([progress_count, objective_count])
