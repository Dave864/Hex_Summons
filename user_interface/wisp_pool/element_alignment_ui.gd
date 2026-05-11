class_name ElementAlignmentUI
extends Control
## Display for the core elements and their alignments.
##
## Looks for signals from the ElementalAlignment autoload to trigger updates to
## the display.


## The enum value for light alignment.
const LIGHT := Element.Alignment.LIGHT
## The enum value for dark alignment.
const DARK := Element.Alignment.DARK


## The timer for triggering shine.
@export var timer: VariableTimer = null
@export_group("Light Alignment Icons", "light_")
## The animated icon for light element.
@export var light_alignment_icon: AlignmentElementIcon = null
## The animated icon for the first element aligned with light.
@export var light_elem_1_icon: CoreElementIcon = null
## The animated icon for the second element aligned with light.
@export var light_elem_2_icon: CoreElementIcon = null
@export_group("Dark Alignment Icons", "dark_")
## The animated icon for dark element.
@export var dark_alignment_icon: AlignmentElementIcon = null
## The animated icon for the first element aligned with dark.
@export var dark_elem_1_icon: CoreElementIcon = null
## The animated icon for the second element aligned with dark.
@export var dark_elem_2_icon: CoreElementIcon = null


## Called when the node enters the scene tree for the first time.
func _ready():
	ElementalAlignment.connect(
			"alignment_changed",
			Callable(self, "_on_ElementalAlignment_alignment_changed")
	)
	_set_icons()


## Sets the icons for the core elements.
func _set_icons() -> void:
	light_elem_1_icon.set_element(light_elem_1_icon.element)
	light_elem_2_icon.set_element(light_elem_2_icon.element)
	dark_elem_1_icon.set_element(dark_elem_1_icon.element)
	dark_elem_2_icon.set_element(dark_elem_2_icon.element)


## Shines all the element icons at set intervals.
func _on_Timer_timeout() -> void:
	light_alignment_icon.shine()
	light_elem_1_icon.change_element(light_elem_1_icon.element, false)
	light_elem_2_icon.change_element(light_elem_2_icon.element, false)
	dark_alignment_icon.shine()
	dark_elem_1_icon.change_element(dark_elem_1_icon.element, false)
	dark_elem_2_icon.change_element(dark_elem_2_icon.element, false)


## Changes the core element icons and all labels to reflect the change in alignment.
func _on_ElementalAlignment_alignment_changed() -> void:
	timer.paused = true
	var light_elems := ElementalAlignment.get_light_elements()
	var dark_elems := ElementalAlignment.get_dark_elements()
	var light_changed: bool = false
	var dark_changed: bool = false
	if light_elems[0] != light_elem_1_icon.element:
		light_changed = true
		light_elem_1_icon.change_element(light_elems[0])
	if light_elems[1] != light_elem_2_icon.element:
		light_changed = true
		light_elem_2_icon.change_element(light_elems[1])
	if dark_elems[0] != dark_elem_1_icon.element:
		dark_changed = true
		dark_elem_1_icon.change_element(dark_elems[0])
	if dark_elems[1] != dark_elem_2_icon.element:
		dark_changed = true
		dark_elem_2_icon.change_element(dark_elems[1])
	if light_changed:
		light_alignment_icon.shine()
	if dark_changed:
		dark_alignment_icon.shine()
	timer.reset()
	timer.paused = false
