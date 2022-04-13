extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_WaterMap_liquid_cell_capacity_over_threshold(cell_position):
	print(cell_position, " is over threshold and you could spawn an area2d or something else!")


func _on_WaterMap_liquid_cell_capacity_under_threshold(cell_position):
	print(cell_position, " is under threshold and you could remove an area2d or something else!")
