extends CharacterBody2D

const speed = 200
var direction = 1
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
const enemy_max_health = 100
var enemy_current_healh = enemy_max_health
var damage = 100

var target_position 

var target

var currenthealth = 300
var maxhealth = 300


@onready var raycastleft = $Raycastleft
@onready var raycastright = $Raycastright
@onready var animated_sprite = $AnimatedSprite2D
#@onready var player = get_tree().get_node("player")


enum {MOVE,
	ATTACK,
	FOLLOW,
}
	
var state = MOVE

func _physics_process(delta):
	match state:
		MOVE:
			move(delta)
		FOLLOW:
			follow(delta)
	
	if target != null:
		state = FOLLOW
		
		target_position = target.global_position
	if raycastright.is_colliding() == true or raycastleft.is_colliding() == true:
		state = MOVE
	
	$ProgressBar.value = currenthealth
	
	
func _process(delta):
	pass
	

func move(delta):
	if raycastright.is_colliding():
		direction = -1
		animated_sprite.flip_h = true
	if raycastleft.is_colliding():
		direction = 1
		animated_sprite.flip_h = false
	position.x += direction * speed * delta
	
	
func follow(delta):
	
		
	direction = (target_position-global_position).normalized()
	if raycastright.is_colliding() == false and raycastleft.is_colliding() == false:	
		position.x += direction.x * speed * delta
	else:
		target = null
	
		

func death():
	queue_free()
		

func damage_taken(hit):
	

	if hit < currenthealth:
		currenthealth -= hit
		print(currenthealth)
	else: 
		currenthealth = 0
	if currenthealth == 0:
		death()
	$ProgressBar.value = currenthealth
	
	
func _on_hitbox_body_entered(body):
	if body.is_in_group("player"):
		get_tree().call_group("player", "damage_taken", damage)


func _on_detection_body_entered(body):
	if body.is_in_group("player"):
		target = body
