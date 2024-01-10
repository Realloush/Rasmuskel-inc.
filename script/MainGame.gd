extends Node2D

func _ready():
	#Engine.max_fps = 60
	pass
func _input(event):
	if event.is_action_pressed("pause"):
		get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")


