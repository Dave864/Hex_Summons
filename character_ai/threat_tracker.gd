class_name ThreatTracker
extends Object
"""
Tracks the threat level of various characters with respect to an observer
character.
"""


var _observer_id: int = -1
var _threat_values: Dictionary = {}
var _decay_rate: float = 2.0


# Returns the player threat values recorded by the observer.
func get_player_threat_values() -> Dictionary:
	var p_threat_values: Dictionary = {}
	for c_id in _threat_values.keys():
		if _threat_values[c_id]["character_type"] == Character.Type.PLAYER:
			p_threat_values[c_id] = _threat_values[c_id]["value"]
	return p_threat_values


# Returns the enemy threat values recorded by the observer.
func get_enemy_threat_values() -> Dictionary:
	var e_threat_values: Dictionary = {}
	for c_id in _threat_values.keys():
		if _threat_values[c_id]["character_type"] == Character.Type.ENEMY:
			e_threat_values[c_id] = _threat_values[c_id]["value"]
	return e_threat_values


# Add the character to the threat tracker if they are not already present.
func add_threat(c: Character) -> void:
	if not _threat_values.has(c.get_instance_id()):
		_threat_values[c.get_instance_id()] = {
			"value": 0.0,
			"character_type": c.get_type(),
			"active": false
		}


# Removes the specified character from the threat tracker.
func remove_threat(c: Character) -> void:
	_threat_values.erase(c.get_instance_id())


# Decreases the threat rate of all characters that have not acted.
func decay_threat() -> void:
	for c_id in _threat_values.keys():
		if _threat_values[c_id]["active"]:
			_threat_values[c_id]["value"] /= _decay_rate


# Resets the active state of all characters.
func reset_active() -> void:
	for c_id in _threat_values.keys():
		_threat_values[c_id]["active"] = false


# Initializes the object.
func _init(observer_id: int, p_chars: Array, e_chars: Array) -> void:
	_observer_id = observer_id
	for p_char in p_chars:
		_threat_values[p_char.get_instance_id()] = {
			"value": 0.0,
			"character_type": Character.Type.PLAYER,
			"active": false
		}
	for e_char in e_chars:
		_threat_values[e_char.get_instance_id()] = {
			"value": 0.0,
			"character_type": Character.Type.ENEMY,
			"active": false
		}
	ErrorUtil.connect_signal(
			SignalBus,
			"health_changed",
			self,
			"_on_SignalBus_health_changed"
	)


# Updates the threat value based on the amount of damage or healing a character
# does. Overhealing and overkilling are not mitigated.
func _on_SignalBus_health_changed(
	caster_id: int,
	target_id: int,
	change_amount: float
) -> void:
	# Don't adjust threat if caster is observer
	if caster_id == _observer_id:
		return
	_threat_values[caster_id]["value"] += abs(change_amount)
	# Double threat if damage is done to this observer
	if (
		target_id == _observer_id
		and change_amount < 0
	):
		_threat_values[caster_id]["value"] += abs(change_amount)
	_threat_values[caster_id]["active"] = true
