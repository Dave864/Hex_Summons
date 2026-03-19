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
]
## The UV coordinates for the side of the mesh. Each side segment uses the same
## texture (or is at least supposed to).
const UV_SIDE: PackedVector2Array = [
	Vector2(0.26, 0.79), # top left
	Vector2(0.72, 0.98), # bottom right
	Vector2(0.26, 0.98), # bottom left
	Vector2(0.72, 0.79), # top right
]


## Creates an array mesh for the hex tile.
func _update_mesh(height: int):
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	
	var verts = PackedVector3Array()
	var uvs = PackedVector2Array()
	var normals = PackedVector3Array()
	var indices = PackedInt32Array()
	
	_create_side_segments(height, verts, normals, uvs, indices)
	_create_top_cap(height, verts, normals, uvs, indices)
	
	# Assign arrays to surface array.
	surface_array[Mesh.ARRAY_VERTEX] = verts
	surface_array[Mesh.ARRAY_TEX_UV] = uvs
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_INDEX] = indices
	
	var array_mesh := ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	mesh = array_mesh


## Creates the sides of the hex mesh, setting the UVs to match the reference
## texture: res://art/hex_base_texture.png
func _create_side_segments(
	height: int,
	verts: PackedVector3Array,
	normals: PackedVector3Array,
	uvs: PackedVector2Array,
	indices: PackedInt32Array
) -> void:
	var base_vert := Vector3(0.0, 0.0, -HexUtil.HEX_TILE_RADIUS)
	for h: int in height + 1:
		base_vert.y = HexUtil.HEX_TILE_UNIT_HEIGHT * (h - 1)
		# Create ring of faces
		for i: int in 6:
			var base_index: int = verts.size()
			# Define vertices for a face.
			var vert_br := base_vert.rotated(Vector3.UP, PI / 3.0 * i)
			var vert_tr := vert_br
			vert_tr.y += HexUtil.HEX_TILE_UNIT_HEIGHT
			var vert_bl := base_vert.rotated(Vector3.UP, PI / 3.0 * (i + 1))
			var vert_tl := vert_bl
			vert_tl.y += HexUtil.HEX_TILE_UNIT_HEIGHT
			verts.append_array([vert_br, vert_tr, vert_tl, vert_bl])
			# Determine normals for lighting.
			var n_rigt := Vector3(vert_br.x, 0.0, vert_br.z).normalized()
			var n_left := Vector3(vert_bl.x, 0.0, vert_bl.z).normalized()
			normals.append_array([n_rigt, n_rigt, n_left, n_left])
			# Assign UVs for vertices.
			uvs.append_array([UV_SIDE[1], UV_SIDE[3], UV_SIDE[0], UV_SIDE[2]])
			# Define triangles for face
			indices.append_array([base_index, base_index + 1, base_index + 3])
			indices.append_array([base_index + 1, base_index + 2, base_index + 3])


## Creates the top of the hex mesh, setting the UVs to match the reference
## texture: res://art/hex_base_texture.png
func _create_top_cap(
	height: int,
	verts: PackedVector3Array,
	normals: PackedVector3Array,
	uvs: PackedVector2Array,
	indices: PackedInt32Array
) -> void:
	var base_index: int = verts.size()
	# Create vertices.
	var top_height: float = HexUtil.HEX_TILE_UNIT_HEIGHT * height
	var start_vert := Vector3(0.0, top_height, -HexUtil.HEX_TILE_RADIUS)
	for i: int in 6:
		var vert: Vector3 = start_vert.rotated(Vector3.UP, PI / 3.0 * i)
		verts.append(vert)
		normals.append(Vector3.UP)
		uvs.append(UV_TOP[i])
	# Define triangles using indices.
	# Top Triangle
	indices.append_array([base_index, base_index + 5, base_index + 1])
	# Upper Middle Triangle
	indices.append_array([base_index + 5, base_index + 2, base_index + 1])
	# Lower Middle Triangle
	indices.append_array([base_index + 2, base_index + 5, base_index + 4])
	# Bottom Triangle
	indices.append_array([base_index + 3, base_index + 2, base_index + 4])


## Triggers an update to the shape height.
func _on_HeightSource_height_changed(height: int) -> void:
	var original_material: Material = null
	if mesh != null:
		original_material = mesh.surface_get_material(0)
	_update_mesh(height)
	mesh.surface_set_material(0, original_material)
