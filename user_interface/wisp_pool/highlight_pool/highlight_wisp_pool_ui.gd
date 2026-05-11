class_name HighlightWispPoolUI
extends WispPoolUI
## A WispPoolUI that has additional UI elements for core element highlights.
##
## This wisp pool UI is able to have the core element icons be blank. The
## core element highlights are used to inidicate what element blank core
## elements are.


## Corresponds to a blank element.
const BLANK_ELEMENT := -1

@export_group("Light Element Highlights", "light_")
## The animated icon for the highlight of the first element aligned with light.
@export var light_highlight_1: CoreElementIcon = null
## The animated icon for the highlight of the second element aligned with light.
@export var light_highlight_2: CoreElementIcon = null
@export_group("Dark Element Highlights", "dark_")
## The animated icon for the highlight of the first element aligned with dark.
@export var dark_highlight_1: CoreElementIcon = null
## The animated icon for the highlight of the second element aligned with dark.
@export var dark_highlight_2: CoreElementIcon = null

## Tracks which core element icons are blank. A blank icon has a wisp count
## of 0.
var _blank_elements: Dictionary[Element.Core, bool] = {
	Element.Core.EARTH: false,
	Element.Core.FIRE: false,
	Element.Core.WATER: false,
	Element.Core.WIND: false,
}


## Checks the provided element against the blank elements record to see if it
## should be blank.
func _blank_mask(element: Element.Core) -> int:
	return BLANK_ELEMENT if _blank_elements[element] else element


## Sets the icons for the core elements and highlights.
func _set_icons() -> void:
	var light_elem_1: Element.Core = _alignments[LIGHT][0]
	var light_elem_2: Element.Core = _alignments[LIGHT][1]
	var dark_elem_1: Element.Core = _alignments[DARK][0]
	var dark_elem_2: Element.Core = _alignments[DARK][1]
	light_elem_1_icon.set_element(_blank_mask(light_elem_1))
	light_highlight_1.set_element(light_elem_1)
	light_elem_2_icon.set_element(_blank_mask(light_elem_2))
	light_highlight_2.set_element(light_elem_2)
	dark_elem_1_icon.set_element(_blank_mask(dark_elem_1))
	dark_highlight_1.set_element(dark_elem_1)
	dark_elem_2_icon.set_element(_blank_mask(dark_elem_2))
	dark_highlight_2.set_element(dark_elem_2)


## Sets the labels for the elements.
func _set_labels() -> void:
	var light_elems: Array[Element.Core] = ElementalAlignment.get_light_elements()
	var dark_elems: Array[Element.Core] = ElementalAlignment.get_dark_elements()
	var light_elem_1_count: int = pool.active_element_count(
			light_elems[0] as Element.Type
	)
	var light_elem_2_count: int = pool.active_element_count(
			light_elems[1] as Element.Type
	)
	var dark_elem_1_count: int = pool.active_element_count(
			dark_elems[0] as Element.Type
	)
	var dark_elem_2_count: int = pool.active_element_count(
			dark_elems[1] as Element.Type
	)
	_blank_elements[light_elems[0]] = light_elem_1_count == 0
	_blank_elements[light_elems[1]] = light_elem_2_count == 0
	_blank_elements[dark_elems[0]] = dark_elem_1_count == 0
	_blank_elements[dark_elems[1]] = dark_elem_2_count == 0
	light_label.text = String.num_uint64(pool.active_light_count())
	light_elem_1_label.text = String.num_uint64(light_elem_1_count)
	light_elem_2_label.text = String.num_uint64(light_elem_2_count)
	dark_label.text = String.num_uint64(pool.active_dark_count())
	dark_elem_1_label.text = String.num_uint64(dark_elem_1_count)
	dark_elem_2_label.text = String.num_uint64(dark_elem_2_count)


## Shines the highlight icons at set intervals.
func _on_Timer_timeout() -> void:
	light_highlight_1.change_element(_alignments[LIGHT][0], false)
	light_highlight_2.change_element(_alignments[LIGHT][1], false)
	dark_highlight_1.change_element(_alignments[DARK][0], false)
	dark_highlight_2.change_element(_alignments[DARK][1], false)


## Changes the core element icons, highlights, and all labels to reflect the
## change in polarity.
func _on_ElementalAlignment_alignment_changed() -> void:
	timer.paused = true
	var light_elems: Array[Element.Core] = ElementalAlignment.get_light_elements()
	var dark_elems: Array[Element.Core] = ElementalAlignment.get_dark_elements()
	var light_changed: bool = false
	var dark_changed: bool = false
	if light_elems[0] != _alignments[LIGHT][0]:
		light_changed = true
		light_elem_1_icon.change_element(_blank_mask(light_elems[0]))
		light_highlight_1.change_element(light_elems[0])
	if light_elems[1] != _alignments[LIGHT][1]:
		light_changed = true
		light_elem_2_icon.change_element(_blank_mask(light_elems[1]))
		light_highlight_2.change_element(light_elems[1])
	if dark_elems[0] != _alignments[DARK][0]:
		dark_changed = true
		dark_elem_1_icon.change_element(_blank_mask(dark_elems[0]))
		dark_highlight_1.change_element(dark_elems[0])
	if dark_elems[1] != _alignments[DARK][1]:
		dark_changed = true
		dark_elem_2_icon.change_element(_blank_mask(dark_elems[1]))
		dark_highlight_2.change_element(dark_elems[1])
	if light_changed:
		light_alignment_icon.shine()
	if dark_changed:
		dark_alignment_icon.shine()
	_alignments[LIGHT] = light_elems.duplicate()
	_alignments[DARK] = dark_elems.duplicate()
	timer.reset()
	timer.paused = false


## Update the label for the corresponding element.
func _on_WispPool_active_count_changed(element: int) -> void:
	var icon_shined: bool = true
	if element == Element.Type.LIGHT:
		light_alignment_icon.shine()
	elif element == Element.Type.DARK:
		dark_alignment_icon.shine()
	elif _alignments[LIGHT][0] == element:
		_blank_elements[element] = pool.active_element_count(element) == 0
		light_elem_1_icon.change_element(_blank_mask(element))
	elif _alignments[LIGHT][1] == element:
		_blank_elements[element] = pool.active_element_count(element) == 0
		light_elem_2_icon.change_element(_blank_mask(element))
	elif _alignments[DARK][0] == element:
		_blank_elements[element] = pool.active_element_count(element) == 0
		dark_elem_1_icon.change_element(_blank_mask(element))
	elif _alignments[DARK][1] == element:
		_blank_elements[element] = pool.active_element_count(element) == 0
		dark_elem_2_icon.change_element(_blank_mask(element))
	else:
		icon_shined = false
	# Update the icon labels in the event where the UI element is not visible
	# for the animations to play.
	if not visible and icon_shined and element in Element.Alignment.values():
		_on_AlignmentElementIcon_shine_ping(element)
	elif not visible and icon_shined:
		_on_CoreElementIcon_element_ping(element)
