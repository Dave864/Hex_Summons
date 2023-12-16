tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("HexMap", 
		"Spatial", 
		preload("HexMap.gd"), 
		preload("Node3D.svg"))


func _exit_tree():
	remove_custom_type("HexMap")
