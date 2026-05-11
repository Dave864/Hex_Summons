@tool
class_name MapTileMesh
extends ScalingHexMesh
## A ScalingHexMesh that is used as a map tile. Provides functions that update
## the material settings of the mesh.


## The reference texture for map tiles.
var _default_texture: Texture2D = preload(Constants.MAP_TEXTURE_REF)


## Updates the texture of the tile. Sets the texture to the reference texture if
## given a null texture.
func set_texture(new_texture: Texture2D) -> void:
	if mesh == null:
		printerr("Mesh not created for MapTileMesh")
		return
	var material: StandardMaterial3D = mesh.surface_get_material(0)
	if material == null:
		printerr("Material not set for MapTileMesh")
		return
	material.albedo_texture = (
		_default_texture if new_texture == null
		else new_texture
	)


## Sets the border color for the tile. The border is rendered as a shader
## material in the next pass of the mesh material.
func set_border_color(new_color: Color) -> void:
	if mesh == null:
		printerr("Mesh not created for MapTileMesh")
		return
	var material: StandardMaterial3D = mesh.surface_get_material(0)
	if material == null:
		printerr("Material not set for MapTileMesh")
		return
	var sobel_outline: ShaderMaterial = material.next_pass
	if sobel_outline == null:
		printerr("ShaderMaterial not set in next pass for ScalingHexMesh.")
		return
	sobel_outline.set_shader_parameter("outline_color", new_color)
