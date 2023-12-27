tool
class_name HexMap
extends Spatial
"""
Initializes the nodes associated with a battle map and makes them available 
in the editor. The following hierarchy is generated:
	HexMap
		FloorMesh
		Tiles
			MapTile
			MapTile2
			...
"""


const TILES: String = "Tiles"
const TILES_SCRIPT: Script = preload("res://hex_map/tiles.gd")
const FLOOR_MESH: String = "FloorMesh"

export(int, 1, 50) var z_count = 3 setget set_z_count
export(int, 1, 50) var x_count = 2 setget set_x_count

# Referene to the scene tree root.
onready var _root_node: Node = get_tree().edited_scene_root


# Called when the node enters the scene tree for the first time.
func _ready():
	# Create the nodes associated with the battle map.
	_create_floor_mesh()
	_create_tiles_node()


# Create mesh to serve as the floor.
func _create_floor_mesh():
	if !has_node(FLOOR_MESH):
		# Create a black color material.
		var color: SpatialMaterial = SpatialMaterial.new()
		color.albedo_color = Color.black
		
		# Create a plane with length and width of 50.0.
		var floor_mesh: MeshInstance = MeshInstance.new()
		floor_mesh.mesh = PlaneMesh.new()
		floor_mesh.mesh.set_size(Vector2(50.0, 50.0))
		floor_mesh.mesh.set_material(color)
		
		floor_mesh.name = FLOOR_MESH
		add_child(floor_mesh)
		floor_mesh.translation = Vector3(0.0, -0.5, 0.0)
		floor_mesh.set_owner(_root_node)


# Creates the Tiles node if it has not already been made
func _create_tiles_node():
	if !has_node(TILES):
		var tiles = Tiles.new()
		add_child(tiles)
		_set_node_properties(tiles, TILES, TILES_SCRIPT)
	$Tiles.set_x_count(x_count)
	$Tiles.set_z_count(z_count)


# Assign the name and the script of a node.
func _set_node_properties(n: Node, name: String, script: Script):
	n.name = name
	n.set_script(script)
	n.set_process(true)
	n.set_owner(_root_node)


func set_z_count(value: int):
	z_count = value
	if has_node(TILES):
		$Tiles.set_z_count(value)


func set_x_count(value: int):
	x_count = value
	if has_node(TILES):
		$Tiles.set_x_count(value)


# Retrieve the map tiles of this hex map.
func get_map_tiles() -> Array:
	return $Tiles.get_children()
