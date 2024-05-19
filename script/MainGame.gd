extends Node2D

#@export var playerpath = NodePath()
#@onready var player = get_parent().get_node("player")
#@onready var pathfollow2d = player.get("path_follow_2d")


func _ready():
	pass



func _input(event):
	if event.is_action_pressed("pause"):
		get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")


