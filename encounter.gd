class_name Encounter
extends Node
"""
Manages the events of an encounter.
"""


# Reference to the encounter hex_map
export(NodePath) var hex_map_path = null

var _rf: RangeFinder
var _initiative_tracker: Array
var _current_initiative: int = 0

onready var character: PlayerCharacter = $PlayerCharacter
onready var enemy: EnemyCharacter = $EnemyCharacter
onready var selector: Selector = $Selector


# Called when the node enters the scene tree for the first time.
func _ready():
	var hex_map: HexMap = get_node(hex_map_path)
	_rf = RangeFinder.new(
		hex_map.x_count,
		hex_map.z_count,
		hex_map.get_map_tiles()
	)
	
	_initiative_tracker.append("Player")
	_initiative_tracker.append("Enemy")


func _process(_delta):
	# When the Player Character enters the `Wait` state, tell the Enemy
	# Character to start its turn.
	if (
		_initiative_tracker[_current_initiative] == "Player" and
		StateMachineBus.encounter_states["PlayerCharacter"] == "Wait"
	):
		SignalBus.emit_signal(
			"enemy_turn_started",
			_rf.calculate_path(
				enemy.get_index_at(),
				character.get_index_at()
			)
		)
		_update_initiative()
	
	# When the Enemy Character enters the `Wait` state, tell the Player
	# Character to start its turn.
	elif (
		_initiative_tracker[_current_initiative] == "Enemy" and
		StateMachineBus.encounter_states["EnemyCharacter"] == "Wait"
	):
		SignalBus.emit_signal("player_turn_started")
		_update_initiative()


func _update_initiative():
	_current_initiative += 1
	_current_initiative = (
		0 if _current_initiative == _initiative_tracker.size() 
		else _current_initiative
	)


func _on_Selector_tile_selected(tile: MapTile):
	SignalBus.emit_signal(
		"tile_selected",
		_rf.calculate_path(
			character.get_index_at(),
			tile.get_index()
		)
	)
