class_name CoreStats
extends Resource
"""
Defines the core stats used by all characters: Health, Attack, Defense, Agility, Movement.
"""

# The core stats used by characters and actions.
enum Type {HEALTH, ATTACK, DEFENSE, AGILITY, MOVEMENT}

# Base stat values
export(int, 0, 1000) var health_base = 1
export(int, 0, 1000) var health_growth = 1
export(int, 0, 1000) var attack_base = 1
export(int, 0, 1000) var attack_growth = 1
export(int, 0, 1000) var defense_base = 1
export(int, 0, 1000) var defense_growth = 1
export(int, 0, 1000) var agility_base = 1
export(int, 0, 1000) var agility_growth = 1
export(int, 1, 20) var movement = 1
