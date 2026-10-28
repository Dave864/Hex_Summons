class_name Options
extends Control
## Manages opening and closing of options menu.
##
## Sets initial focus when opened. Does not actually close the menu, but emits
## a signal indicating that it should be closed.


## Indicates that this menu is to be closed.
signal closed

## Flag that indicates that this menu is open.
var is_open := false

## The tab menu for the options.
@onready var menu: TabContainer = $TabContainer


## Checks if the menu should be closed.
func _input(event: InputEvent) -> void:
	if not is_open:
		return
	if event.is_action("ui_cancel"):
		closed.emit()
		is_open = false


## Sets the focus to the first tab in the menu
func open() -> void:
	is_open = true
	menu.current_tab = 0
