class_name Wisp
extends Resource
"""
Defines the details of a wisp, such as its element, associated art, and bonuses
to set character.
"""


enum Element {
	EARTH,
	FIRE,
	WATER,
	WIND,
}

@export var element: Element = Element.EARTH
@export var portrait: Texture2D = load(Constants.DEFAULT_ICON_PATH)
@export var effect_bonus: Resource =  null
