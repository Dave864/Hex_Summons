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
# How far away the attack can be placed. A value of zero indicates that the
# attack origninates from the character's position.
export(int, 20) var start_range = 0
# The number of tiles emaniting outwards the attack affects.
export(int, 1, 20) var reach = 1
# The number of tiles adjacent to the start position the attack effects.
export(int, 1, 6) var spread = 1
# The highlighter color used to indicate the attack's area of effect.
export(SpatialMaterial) var highlight_color = null
