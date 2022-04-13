tool
extends EditorPlugin


func _enter_tree():
	# Initialization of the plugin goes here.
	add_custom_type("WaterMap", "Node2D", preload("WaterMap.gd"), preload("icon.png"))


func _exit_tree():
	# Clean-up of the plugin goes here.
	remove_custom_type("WaterMap")
