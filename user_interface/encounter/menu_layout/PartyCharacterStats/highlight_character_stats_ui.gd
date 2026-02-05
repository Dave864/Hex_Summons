class_name HighlightCharacterStatsUI
extends UserCharacterStatsUI
## The encounter scene UI element that displays a summary of a character,
## usually player or summon. Also is able to highlight itself.


## A background panel that can be toggled on or off to indicate that this UI
## element is highlighted.
@onready var _highlighted_indicator: Panel = $HighlightedIndicator


## Sets the highlight indicator to the active value. True means the highlight is
## visible. False means it is hidden.
func set_highlight(active: bool) -> void:
	_highlighted_indicator.visible = active
