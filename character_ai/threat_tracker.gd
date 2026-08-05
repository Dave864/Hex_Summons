class_name ThreatTracker
extends Object
## Tracks the threat level of various characters with respect to an observer
## character.


## The minimum amount of threat a character can have.
const MIN_THREAT: float = 1.0
## An invalid character id.
const INVALID_ID: int = -1

## The id of the observer.
var _observer_id: int = -1
## Tracks the threat values of characters.
var _threat_values: Dictionary[int, ThreatData] = {}:
	get = get_threat_values
## Tracks the original threat values of a summoner.
var _summoner_data: Dictionary[String, Variant] = {
	"id": INVALID_ID,
	"old_value": 0.0
}
## The rate at which threat decays for tracked characters.
var _decay_rate: float = 2.0


## Initializes the object.
func _init(observer_id: int, chars: Array[Character], summon: Summon) -> void:
	_observer_id = observer_id
	for c: Character in chars:
		_threat_values[c.get_instance_id()] = ThreatData.new()
		c.defeated.connect(_on_Character_defeated)
	SignalBus.health_changed.connect(_on_SignalBus_health_changed)
	summon.activated.connect(_on_Summon_activated)
	summon.deactivated.connect(_on_Summon_deactivated)


## Returns the threat values recorded by the observer.
func get_threat_values() -> Dictionary[int, ThreatData]:
	return _threat_values


## Add the character to the threat tracker if they are not already present.
func add_threat(c: Character) -> void:
	if not _threat_values.has(c.get_instance_id()):
		_threat_values[c.get_instance_id()] = ThreatData.new()


## Removes the specified character from the threat tracker.
func remove_threat(c: Character) -> void:
	_threat_values.erase(c.get_instance_id())


## Decreases the threat rate of all characters that have not acted.
func decay_threat() -> void:
	for c_id: int in _threat_values.keys():
		if _threat_values[c_id].active:
			var old_value: float = _threat_values[c_id].value
			_threat_values[c_id].value = clampf(
					old_value / _decay_rate,
					MIN_THREAT,
					INF
			)


## Resets the active state of all characters.
func reset_active() -> void:
	for c_id in _threat_values.keys():
		_threat_values[c_id].active = false


## Updates the threat value based on the amount of damage or healing a character
## does. Overhealing and overkilling are not mitigated.
func _on_SignalBus_health_changed(
	caster_id: int,
	target_id: int,
	change_amount: float
) -> void:
	# Don't adjust threat if caster threat is not tracked or if caster is observer
	if !_threat_values.has(caster_id) or caster_id == _observer_id:
		return
	_threat_values[caster_id].value += abs(change_amount)
	# Double threat if damage is done to this observer
	if target_id == _observer_id and change_amount < 0:
		_threat_values[caster_id].value += abs(change_amount)
	_threat_values[caster_id].active = true


## Saves a copy of the summoner's orignal threat values. Does nothing if the
## summoner is not in this ThreatTracker.
func _on_Summon_activated(summoner_id: int) -> void:
	if not _threat_values.has(summoner_id):
		return
	_summoner_data["id"] = summoner_id
	_summoner_data["old_value"] = _threat_values[summoner_id].value


## Restores the summoner's original threat values. Does nothing if no previous
## values were recorded.
func _on_Summon_deactivated() -> void:
	if _summoner_data["id"] == INVALID_ID:
		return
	_threat_values[_summoner_data["id"]].value = _summoner_data["old_value"]


## Removes the defeated character from the threat tracker.
func _on_Character_defeated(character: Character) -> void:
	_threat_values.erase(character.get_instance_id())


## The data associated with threat level.
class ThreatData:
	## The amount of health that has been affected across characters,
	## which correlates to how much of a target something is.
	var value: float = MIN_THREAT
	## Whether the value has been increased recently, indicating that the value
	## should not decay.
	var active: bool = false
	
	
	func _init(
		start_value: float = MIN_THREAT,
		start_active: bool = false
	) -> void:
		value = start_value
		active = start_active
