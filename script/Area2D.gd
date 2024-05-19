extends Area2D
@onready var timer =$Timer
var damage_taken = 0

func _on_body_entered(_body):
	
	timer.start()
	





func _on_timer_timeout():
	get_tree().reload_current_scene()
	
