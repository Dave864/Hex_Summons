class_name WispPoolUI
extends Control
"""
Manages the labels and element icons of the wisp pool.
"""


const LIGHT: int = Constants.PolarElement.LIGHT
const DARK: int = Constants.PolarElement.DARK


export(NodePath) var light_label_ref = NodePath("")
export(NodePath) var light_icon_ref = NodePath("")
export(NodePath) var light_elem_1_label_ref = NodePath("")
export(NodePath) var light_elem_1_icon_ref = NodePath("")
export(NodePath) var light_elem_2_label_ref = NodePath("")
export(NodePath) var light_elem_2_icon_ref = NodePath("")

export(NodePath) var dark_label_ref = NodePath("")
export(NodePath) var dark_icon_ref = NodePath("")
export(NodePath) var dark_elem_1_label_ref = NodePath("")
export(NodePath) var dark_elem_1_icon_ref = NodePath("")
export(NodePath) var dark_elem_2_label_ref = NodePath("")
export(NodePath) var dark_elem_2_icon_ref = NodePath("")

export(NodePath) var timer_ref = NodePath("")

var pool: WispPool = null

onready var light_label: AnimatedLabel = get_node(light_label_ref)
onready var light_icon: PolarElementIcon = get_node(light_icon_ref)
onready var light_elem_1_label: AnimatedLabel = get_node(light_elem_1_label_ref)
onready var light_elem_1_icon: CoreElementIcon = get_node(light_elem_1_icon_ref)
onready var light_elem_2_label: AnimatedLabel = get_node(light_elem_2_label_ref)
onready var light_elem_2_icon: CoreElementIcon = get_node(light_elem_2_icon_ref)

onready var dark_label: AnimatedLabel = get_node(dark_label_ref)
onready var dark_icon: PolarElementIcon = get_node(dark_icon_ref)
onready var dark_elem_1_label: AnimatedLabel = get_node(dark_elem_1_label_ref)
onready var dark_elem_1_icon: CoreElementIcon = get_node(dark_elem_1_icon_ref)
onready var dark_elem_2_label: AnimatedLabel = get_node(dark_elem_2_label_ref)
onready var dark_elem_2_icon: CoreElementIcon = get_node(dark_elem_2_icon_ref)

onready var timer: VariableTimer = get_node(timer_ref)

onready var _polarities: Dictionary = {
	LIGHT: ElementalPolarity.get_light_elements().duplicate(),
	DARK: ElementalPolarity.get_dark_elements().duplicate()
}

# Called when the node enters the scene tree for the first time.
func _ready():
	ElementalPolarity.connect(
			"polarity_changed",
			self,
			"_on_ElementalPolarity_polarity_changed"
	)
	_set_wisp_pool()
	_set_icons()
	_set_labels_on_ready()


# Virtual function. Initializes the wisp pool reference.
func _set_wisp_pool() -> void:
	pass


# Sets the icons for the core elements.
func _set_icons() -> void:
	light_elem_1_icon.set_element(_polarities[LIGHT][0])
	light_elem_2_icon.set_element(_polarities[LIGHT][1])
	dark_elem_1_icon.set_element(_polarities[DARK][0])
	dark_elem_2_icon.set_element(_polarities[DARK][1])


# Sets the labels for the elements.
func _set_labels_on_ready() -> void:
	# Some child classes of WispPoolUI will set the wisp pool after ready is called.
	# Labels should be updated when the pool is assigned in this case.
	if pool == null:
		return
	_set_labels()


# Sets the labels for the elements.
func _set_labels() -> void:
	var light_elems: Array = ElementalPolarity.get_light_elements()
	var dark_elems: Array = ElementalPolarity.get_dark_elements()
	light_label.text = String(pool.active_light_count())
	light_elem_1_label.text = String(pool.active_element_count(light_elems[0]))
	light_elem_2_label.text = String(pool.active_element_count(light_elems[1]))
	dark_label.text = String(pool.active_dark_count())
	dark_elem_1_label.text = String(pool.active_element_count(dark_elems[0]))
	dark_elem_2_label.text = String(pool.active_element_count(dark_elems[1]))


# Shines all the element icons at set intervals.
func _on_Timer_timeout() -> void:
	light_icon.shine()
	light_elem_1_icon.change_element(_polarities[LIGHT][0])
	light_elem_2_icon.change_element(_polarities[LIGHT][1])
	dark_icon.shine()
	dark_elem_1_icon.change_element(_polarities[DARK][0])
	dark_elem_2_icon.change_element(_polarities[DARK][1])


# Changes the core element icons and all labels to reflect the change in polarity.
func _on_ElementalPolarity_polarity_changed() -> void:
	timer.paused = true
	var light_elems: Array = ElementalPolarity.get_light_elements()
	var dark_elems: Array = ElementalPolarity.get_dark_elements()
	var light_changed: bool = false
	var dark_changed: bool = false
	if light_elems[0] != _polarities[LIGHT][0]:
		light_changed = true
		light_elem_1_icon.change_element(light_elems[0])
	if light_elems[1] != _polarities[LIGHT][1]:
		light_changed = true
		light_elem_2_icon.change_element(light_elems[1])
	if dark_elems[0] != _polarities[DARK][0]:
		dark_changed = true
		dark_elem_1_icon.change_element(dark_elems[0])
	if dark_elems[1] != _polarities[DARK][1]:
		dark_changed = true
		dark_elem_2_icon.change_element(dark_elems[1])
	if light_changed:
		light_icon.shine()
	if dark_changed:
		dark_icon.shine()
	_polarities[LIGHT] = light_elems.duplicate()
	_polarities[DARK] = dark_elems.duplicate()
	timer.reset()
	timer.paused = false


# Update the count label for the pinged core element. This signal will only
# be emitted when the element for an icon changes, allowing for periodic
# shines to not play the text change animation.
func _on_CoreElementIcon_element_ping(core_elem: int) -> void:
	var count: String = String(pool.active_element_count(core_elem))
	if _polarities[LIGHT][0] == core_elem:
		light_elem_1_label.update_text(count)
	elif _polarities[LIGHT][1] == core_elem:
		light_elem_2_label.update_text(count)
	elif _polarities[DARK][0] == core_elem:
		dark_elem_1_label.update_text(count)
	elif _polarities[DARK][1] == core_elem:
		dark_elem_2_label.update_text(count)


# Update the count label for the pinged polar element. Will play the update text
# animation if the text updates.
func _on_PolarElementIcon_shine_ping(polar_elem: int) -> void:
	if polar_elem == LIGHT and String(pool.active_light_count()) != light_label.text:
		light_label.update_text(String(pool.active_light_count()))
	elif polar_elem == DARK and String(pool.active_dark_count()) != dark_label.text:
		dark_label.update_text(String(pool.active_dark_count()))


# Update the label for the corresponding element.
func _on_WispPool_active_count_changed(element: int, count: int) -> void:
	if element == Constants.Element.LIGHT:
		pass
	elif element == Constants.Element.DARK:
		pass
	elif element in Constants.CoreElement.keys():
		pass
