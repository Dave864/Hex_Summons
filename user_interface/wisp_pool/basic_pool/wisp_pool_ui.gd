class_name WispPoolUI
extends ElementAlignmentUI
## Manages the labels and element icons of a wisp pool.


@export_group("Light Alignment Labels", "light_")
## The text label for the light element count.
@export var light_label: AnimatedLabel = null
## The text label for the first element aligned with light.
@export var light_elem_1_label: AnimatedLabel = null
## The text label for the second element aligned with light.
@export var light_elem_2_label: AnimatedLabel = null

@export_group("Dark Alignment Labels", "dark_")
## The text label for the dark element count.
@export var dark_label: AnimatedLabel = null
## The text label for the first element aligned with dark.
@export var dark_elem_1_label: AnimatedLabel = null
## The text label for the second element aligned with dark.
@export var dark_elem_2_label: AnimatedLabel = null

## The wisp pool being displayed by this UI element.
var pool: WispPool = null

## The alignments of core elements.
@onready var _alignments: Dictionary[Element.Alignment, Array] = {
	LIGHT: ElementalAlignment.get_light_elements().duplicate(),
	DARK: ElementalAlignment.get_dark_elements().duplicate()
}

## Called when the node enters the scene tree for the first time.
func _ready():
	ElementalAlignment.alignment_changed.connect(
			_on_ElementalAlignment_alignment_changed
	)
	_set_labels_on_ready()
	_set_icons()


## Virtual function. Initializes the wisp pool reference.
func set_wisp_pool(new_pool: WispPool = null) -> void:
	if pool != null:
		pool.active_count_changed.disconnect(_on_WispPool_active_count_changed)
	pool = new_pool
	if new_pool != null:
		pool.active_count_changed.connect(_on_WispPool_active_count_changed)
	_set_labels()
	_set_icons()


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


## Update the count label for the pinged alignment element. Will play the update
## text animation if the text updates.
func _on_AlignmentElementIcon_shine_ping(element: int) -> void:
	# Not able to update labels if no wisp pool is connected.
	if pool == null:
		return
	if (
		element == LIGHT
		and String.num_uint64(pool.active_light_count()) != light_label.text
	):
		light_label.update_text(String.num_uint64(pool.active_light_count()))
	elif (
		element == DARK
		and String.num_uint64(pool.active_dark_count()) != dark_label.text
	):
		dark_label.update_text(String.num_uint64(pool.active_dark_count()))


## Update the label for the corresponding element.
func _on_WispPool_active_count_changed(element: int) -> void:
	var icon_shined: bool = true
	if element == Element.Type.LIGHT:
		light_alignment_icon.shine()
	elif element == Element.Type.DARK:
		light_alignment_icon.shine()
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
