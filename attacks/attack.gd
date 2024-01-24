class_name Attack
extends Node
"""
Describes the common parameters for all attacks, which are split into the 
catergories of either `Technique` or `Spell`. Defines the attack bonus, reach, 
range, and spread of an attack.
"""


# The bonus value of the attack. Added to the appropriate character stat to 
# determine the attack's strength.
export(int, 1, 1000) var atk_bonus = 1
# How far away the attack can be placed. A value of one indicates that the
# attack is adjacent to the character.
export(int, 1, 20) var start_range = 1
# The number of tiles emaniting outwards the attack affects.
export(int, 20) var reach = 0
# The number of tiles adjacent to the start position the attack effects.
export(int, 1, 6) var spread = 1
