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

export(Element) var element = Element.EARTH
export var portrait: Texture = load(Constants.DEFAULT_ICON_PATH)
export(Resource) var effect_bonus =  null
