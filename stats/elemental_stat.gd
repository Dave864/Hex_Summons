extends Node
class_name ElementalStat
"""
Defines an elemental alignment of a stat to one of the four primary elements: 
earth, fire, water, wind.
"""


enum Element {FIRE, EARTH, WATER, WIND}

export(Element) var type = Element.FIRE
export(int, 0, 1000) var base_value = 0
export(int, 0, 1000) var growth_rate = 0
