class_name WispPoolUI
extends Control
"""
Manages the labels and element icons of the wisp pool.
"""


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

var pool: WispPool = null

onready var light_label: Label = get_node(light_label_ref)
onready var light_icon: PolarElementIcon = get_node(light_icon_ref)
onready var light_elem_1_label: Label = get_node(light_elem_1_label_ref)
onready var light_elem_1_icon: CoreElementIcon = get_node(light_elem_1_icon_ref)
onready var light_elem_2_label: Label = get_node(light_elem_2_label_ref)
onready var light_elem_2_icon: CoreElementIcon = get_node(light_elem_2_icon_ref)

onready var dark_label: Label = get_node(dark_label_ref)
onready var dark_icon: PolarElementIcon = get_node(dark_icon_ref)
onready var dark_elem_1_label: Label = get_node(dark_elem_1_label_ref)
onready var dark_elem_1_icon: CoreElementIcon = get_node(dark_elem_1_icon_ref)
onready var dark_elem_2_label: Label = get_node(dark_elem_2_label_ref)
onready var dark_elem_2_icon: CoreElementIcon = get_node(dark_elem_2_icon_ref)


# Called when the node enters the scene tree for the first time.
func _ready():
	_set_wisp_pool()
	_set_icons()
	_set_labels()


# Virtual function. Initializes the wisp pool reference.
func _set_wisp_pool() -> void:
	pass


# Sets the icons for the core elements.
func _set_icons() -> void:
	var light_elems: Array = ElementalPolarity.get_light_elements()
	var dark_elems: Array = ElementalPolarity.get_dark_elements()
	light_elem_1_icon.set_element(light_elems[0])
	light_elem_2_icon.set_element(light_elems[1])
	dark_elem_1_icon.set_element(dark_elems[0])
	dark_elem_2_icon.set_element(dark_elems[1])


# Sets the labels for the elements.
func _set_labels() -> void:
	if pool == null:
		return
	var light_elems: Array = ElementalPolarity.get_light_elements()
	var dark_elems: Array = ElementalPolarity.get_dark_elements()
	light_label.text = String(pool.active_light_count())
	light_elem_1_label.text = String(pool.active_element_count(light_elems[0]))
	light_elem_2_label.text = String(pool.active_element_count(light_elems[1]))
	dark_label.text = String(pool.active_dark_count())
	dark_elem_1_label.text = String(pool.active_element_count(dark_elems[0]))
	dark_elem_2_label.text = String(pool.active_element_count(dark_elems[1]))
