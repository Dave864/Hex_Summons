class_name WispPoolUI
extends Control
## Manages the labels and element icons of the wisp pool.


const LIGHT: int = Element.Alignment.LIGHT
const DARK: int = Element.Alignment.DARK


@export var timer: VariableTimer = null
@export_group("Light Polarity UI Nodes", "light_")
@export var light_label: AnimatedLabel = null
@export var light_icon: AlignmentElementIcon = null
@export_subgroup("Left Element Nodes", "light_elem_1")
@export var light_elem_1_label: AnimatedLabel = null
@export var light_elem_1_icon: CoreElementIcon = null
@export_subgroup("Right Element Nodes", "light_elem_2")
@export var light_elem_2_label: AnimatedLabel = null
@export var light_elem_2_icon: CoreElementIcon = null

@export_group("Dark Polarity UI Elements", "dark_")
@export var dark_label: AnimatedLabel = null
@export var dark_icon: AlignmentElementIcon = null
@export_subgroup("Left Element Nodes", "dark_elem_1")
@export var dark_elem_1_label: AnimatedLabel = null
@export var dark_elem_1_icon: CoreElementIcon = null
@export_subgroup("Right Element Nodes", "dark_elem_2")
@export var dark_elem_2_label: AnimatedLabel = null
@export var dark_elem_2_icon: CoreElementIcon = null

var pool: WispPool = null

@onready var _alignments: Dictionary = {
	LIGHT: ElementalAlignment.get_light_elements().duplicate(),
	DARK: ElementalAlignment.get_dark_elements().duplicate()
}

## Called when the node enters the scene tree for the first time.
func _ready():
	ElementalAlignment.connect(
			"alignment_changed",
			Callable(self, "_on_ElementalAlignment_alignment_changed")
	)
	set_wisp_pool()
	_set_icons()
	_set_labels_on_ready()


## Virtual function. Initializes the wisp pool reference.
func set_wisp_pool(new_pool: WispPool = null) -> void:
	if pool != null:
		pool.disconnect(
				"active_count_changed",
				Callable(self, "_on_WispPool_active_count_changed")
		)
	pool = new_pool
	if new_pool != null:
		pool.connect(
				"active_count_changed",
				Callable(self, "_on_WispPool_active_count_changed")
		)


## Sets the icons for the core elements.
func _set_icons() -> void:
	light_elem_1_icon.set_element(_alignments[LIGHT][0])
	light_elem_2_icon.set_element(_alignments[LIGHT][1])
	dark_elem_1_icon.set_element(_alignments[DARK][0])
	dark_elem_2_icon.set_element(_alignments[DARK][1])


## Sets the labels for the elements.
func _set_labels_on_ready() -> void:
	# Some child classes of WispPoolUI will set the wisp pool after ready is called.
	# Labels should be updated when the pool is assigned in this case.
	if pool == null:
		return
	_set_labels()


## Sets the labels for the elements.
func _set_labels() -> void:
	var light_elems: Array[Element.Core] = ElementalAlignment.get_light_elements()
	var dark_elems: Array[Element.Core] = ElementalAlignment.get_dark_elements()
	light_label.text = String.num_uint64(pool.active_light_count())
	light_elem_1_label.text = String.num_uint64(
			pool.active_element_count(light_elems[0] as Element.Type)
	)
	light_elem_2_label.text = String.num_uint64(
			pool.active_element_count(light_elems[1] as Element.Type)
	)
	dark_label.text = String.num_uint64(pool.active_dark_count())
	dark_elem_1_label.text = String.num_uint64(
			pool.active_element_count(dark_elems[0] as Element.Type)
	)
	dark_elem_2_label.text = String.num_uint64(
			pool.active_element_count(dark_elems[1] as Element.Type)
	)


## Shines all the element icons at set intervals.
func _on_Timer_timeout() -> void:
	light_icon.shine()
	light_elem_1_icon.change_element(_alignments[LIGHT][0], false)
	light_elem_2_icon.change_element(_alignments[LIGHT][1], false)
	dark_icon.shine()
	dark_elem_1_icon.change_element(_alignments[DARK][0], false)
	dark_elem_2_icon.change_element(_alignments[DARK][1], false)


## Changes the core element icons and all labels to reflect the change in polarity.
func _on_ElementalAlignment_alignment_changed() -> void:
	timer.paused = true
	var light_elems: Array[Element.Core] = ElementalAlignment.get_light_elements()
	var dark_elems: Array[Element.Core] = ElementalAlignment.get_dark_elements()
	var light_changed: bool = false
	var dark_changed: bool = false
	if light_elems[0] != _alignments[LIGHT][0]:
		light_changed = true
		light_elem_1_icon.change_element(light_elems[0])
	if light_elems[1] != _alignments[LIGHT][1]:
		light_changed = true
		light_elem_2_icon.change_element(light_elems[1])
	if dark_elems[0] != _alignments[DARK][0]:
		dark_changed = true
		dark_elem_1_icon.change_element(dark_elems[0])
	if dark_elems[1] != _alignments[DARK][1]:
		dark_changed = true
		dark_elem_2_icon.change_element(dark_elems[1])
	if light_changed:
		light_icon.shine()
	if dark_changed:
		dark_icon.shine()
	_alignments[LIGHT] = light_elems.duplicate()
	_alignments[DARK] = dark_elems.duplicate()
	timer.reset()
	timer.paused = false


## Update the count label for the pinged core element. This signal will only
## be emitted when the element for an icon changes, allowing for periodic
## shines to not play the text change animation.
func _on_CoreElementIcon_element_ping(core_elem: int) -> void:
	# Not able to update labels if no wisp pool is connected.
	if pool == null:
		return
	var count: String = String.num_uint64(pool.active_element_count(core_elem))
	if _alignments[LIGHT][0] == core_elem:
		light_elem_1_label.update_text(count)
	elif _alignments[LIGHT][1] == core_elem:
		light_elem_2_label.update_text(count)
	elif _alignments[DARK][0] == core_elem:
		dark_elem_1_label.update_text(count)
	elif _alignments[DARK][1] == core_elem:
		dark_elem_2_label.update_text(count)


## Update the count label for the pinged polar element. Will play the update text
## animation if the text updates.
func _on_AlignmentElementIcon_shine_ping(polar_elem: int) -> void:
	# Not able to update labels if no wisp pool is connected.
	if pool == null:
		return
	if (
		polar_elem == LIGHT
		and String.num_uint64(pool.active_light_count()) != light_label.text
	):
		light_label.update_text(String.num_uint64(pool.active_light_count()))
	elif (
		polar_elem == DARK
		and String.num_uint64(pool.active_dark_count()) != dark_label.text
	):
		dark_label.update_text(String.num_uint64(pool.active_dark_count()))


## Update the label for the corresponding element.
func _on_WispPool_active_count_changed(element: int) -> void:
	var icon_shined: bool = true
	if element == Element.Type.LIGHT:
		light_icon.shine()
	elif element == Element.Type.DARK:
		dark_icon.shine()
	elif _alignments[LIGHT][0] == element:
		light_elem_1_icon.change_element(element)
	elif _alignments[LIGHT][1] == element:
		light_elem_2_icon.change_element(element)
	elif _alignments[DARK][0] == element:
		dark_elem_1_icon.change_element(element)
	elif _alignments[DARK][1] == element:
		dark_elem_2_icon.change_element(element)
	else:
		icon_shined = false
	# Update the icon labels in the event where the UI element is not visible
	# for the animations to play.
	if not visible and icon_shined and element in Element.Alignment.values():
		_on_AlignmentElementIcon_shine_ping(element)
	elif not visible and icon_shined:
		_on_CoreElementIcon_element_ping(element)
