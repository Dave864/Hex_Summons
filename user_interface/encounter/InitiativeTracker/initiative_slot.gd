class_name InitiativeSlot
extends TextureRect
## Displays the portrait, current health, and initiative slot of a given character.


@onready var initiative: Label = $InitPanel/Initiative
@onready var portrait: TextureRect = $Portrait


func _ready() -> void:
	update_portrait(portrait.texture)


## Updates the details of the slot to represent the new character
func change_character(c: Character) -> void:
	update_portrait(c.battle_portrait)
	if c is PlayerCharacter:
		material.set_shader_parameter("new_color", Color.AQUA)
	elif c is Summon:
		material.set_shader_parameter("new_color", Color.GREEN)
	else:
		material.set_shader_parameter("new_color", Color.RED)


## Updates the portrait.
func update_portrait(new_p: Texture2D) -> void:
	portrait.texture = new_p
	var region: Vector4
	if new_p is AtlasTexture:
		region = Vector4(
				new_p.region.position.x,
				new_p.region.position.y,
				new_p.region.size.x,
				new_p.region.size.y
		)
	else:
		region = Vector4(0.0, 0.0, new_p.get_width(), new_p.get_height())
	portrait.material.set_shader_parameter("region", region)


## Updates the number of the initiative label.
func update_initiative_label(init_value: int) -> void:
	initiative.text = String.num_uint64(init_value)
