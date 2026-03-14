@tool
class_name ScalingHexMesh
extends MeshInstance3D
## Enables a MeshInstance3D to be adjustable by outside factors.


## The UV coordinates for the top vertices of the mesh.
const UV_TOP: PackedVector2Array = [
	Vector2(0.98, 0.39),
	Vector2(0.74, 0.01),
	Vector2(0.26, 0.01),
	Vector2(0.02, 0.39),
	Vector2(0.26, 0.76),
	Vector2(0.74, 0.76),
	Vector2(0.98, 0.39),
	Vector2(0.5, 0.39), # center vertex
]
## The UV coordinates for the side of the mesh. Each side segment uses the same
## texture (or is at least supposed to).
const UV_SIDE: PackedVector2Array = [
	Vector2(0.26, 0.79), # top left
	Vector2(0.72, 0.98), # bottom right
	Vector2(0.26, 0.98), # bottom left
	Vector2(0.72, 0.79), # top right
]

## The mesh used to represent a hex tile.
var _hex_mesh: ArrayMesh:
	get:
		return mesh as ArrayMesh


## Updates the shape mesh so that it reflects the current height.
func _update_tile_shape_height(height: int) -> void:
	# Move the shape so that the bottom is always at -0.25
	mesh = _create_base_mesh(height)
	var y_translate: float = (HexUtil.HEX_TILE_UNIT_HEIGHT / 2) * (height - 1)
	set_position(Vector3(0.0, y_translate, 0.0))
	print("HEIGHT: %d" % height)
	_update_uvs()


## Update the UV map of the mesh to align with the base texture:
## res://art/hex_base_texture.png
func _update_uvs() -> void:
	var mesh_data := MeshDataTool.new()
	mesh_data.create_from_surface(_hex_mesh, 0)
	var vertex_count: int = mesh_data.get_vertex_count()
	## Set the UVs for the top cap of the mesh.
	for i: int in UV_TOP.size():
		mesh_data.set_vertex_uv(vertex_count - i - 1, UV_TOP[i])
	## Set the UVs for the side segments of the mesh.
	var even_row: int
	var even_vertex: int
	for i: int in vertex_count - UV_TOP.size():
		even_row = i % 2
		even_vertex = i % 7 % 2
		mesh_data.set_vertex_uv(i, UV_SIDE[even_row * 2 + even_vertex])
	mesh_data.commit_to_surface(_hex_mesh)


## Creates an array mesh for the hex tile of the specified height.
func _create_base_mesh(height: int) -> ArrayMesh:
	var cylinder_mesh := CylinderMesh.new()
	cylinder_mesh.top_radius = HexUtil.HEX_TILE_RADIUS
	cylinder_mesh.bottom_radius = HexUtil.HEX_TILE_RADIUS
	cylinder_mesh.height = HexUtil.HEX_TILE_UNIT_HEIGHT * (1 + height)
	cylinder_mesh.radial_segments = 6
	cylinder_mesh.rings = height
	cylinder_mesh.cap_bottom = false
	var array_mesh := ArrayMesh.new()
	array_mesh.add_surface_from_arrays(
			Mesh.PRIMITIVE_TRIANGLES,
			cylinder_mesh.get_mesh_arrays()
	)
	return array_mesh


## Triggers an update to the shape height.
func _on_HeightSource_height_changed(height: int) -> void:
	_update_tile_shape_height(height)
