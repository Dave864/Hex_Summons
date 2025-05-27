class_name Stat
extends Resource
"""
Defines the stats used by all characters: Health, Attack, Defense, Agility, Movement.
"""


# The core stats used by characters and actions.
enum Type {CUR_HEALTH, MAX_HEALTH, ATTACK, DEFENSE, AGILITY, MOVEMENT}

export(Type) var type = Type.CUR_HEALTH
