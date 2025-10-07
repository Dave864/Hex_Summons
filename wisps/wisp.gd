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
export var portrait: Texture = null
export(Resource) var effect_bonus =  null
