class_name Action
extends Node
"""
Describes the range, damage profile, and effects of an action.
"""


export(int, 1, 1000) var power

onready var range_data: ActionRange = $Range
