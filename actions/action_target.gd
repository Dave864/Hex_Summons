class_name ActionTarget
extends Resource
"""
Defines the valid targets for an action, either self, allies, or opponents.
"""


enum Type {SELF, ALLIES, OPPONENTS}

export(Type) var target = Type.OPPONENTS
