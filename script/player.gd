extends CharacterBody2D

@onready var coyote_jump_timer = $CoyoteJumpTimer
@onready var jump_buffer = $JumpBuffer
@onready var collision = $CollisionShape2D
@onready var animated_sprite = $AnimatedSprite2D
#@onready var ap = $AnimationPlayer




#physics 
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var friction = 8000.0
var acceleration = 9000.0
var air_resistence = 8000.0
#basic movement var
var can_move = true
var normal_speed = 1000
var direction_facing = 1
var can_jump = true
#var horizontal_direction = Input.get.axis("move-left", "move rigt")
#jump var
var jump_velocity = -1300
var double_jump_velocity = -1150
var can_double_jump = true
#Wall Jump
const wall_jump_pushback = 3500
const wall_jump_velocity = Vector2(900, -1500)
var can_walljump = false
var is_wall_jumping = false
var list = []
var WPING = false

#Wall Slide
var is_wall_sliding = false 
const wall_slide_gravity = 100
var wall_slide_speed = 300
#dash
var canDash = true
var dashing = false
var dashspeed = 8000




func _input(_event):
	if Input.is_action_pressed("shift"):
		dash()
	if Input.is_action_just_pressed("ui_accept"):
		Jump()
	if((Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right") or Input.is_action_just_released("ui_left") or Input.is_action_just_released("ui_right")) or abs(Input.get_joy_axis(0,0))> 0.3):
		pass
	




func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		
	


func coyote_jump():
		# Coyote jump
	var was_on_floor = is_on_floor()
	
	var just_left_ledge = was_on_floor and not is_on_floor()
	if just_left_ledge:
		coyote_jump_timer.start()
func _physics_process(delta):
		
	if is_on_wall() == true:
		is_wall_sliding = true
	else: 
		is_wall_sliding = false
	
	

	if Input.is_action_just_pressed("ui_right"):
		direction_facing = -1

		
	if Input.is_action_just_pressed("ui_left"):
		direction_facing = 1

	

	

	#Double Jump
	#if Input.is_action_just_pressed("ui_accept") and not is_on_floor() and can_double_jump and not is_on_wall:
		#velocity.y = double_jump_velocity
		#can_double_jump = false
		#gravity = 2100
		
	if velocity.y <5 and velocity.y > -5 and not dashing:
		gravity = 2100
	# When falling gravity becomes stronger
	
			
	# Resets gravity when on floor
	if is_on_floor():
		gravity = 2000
		can_double_jump = true
		can_jump = true
		
	
		
	# Jump height
	if Input.is_action_just_released("ui_accept") and not velocity.y > -30:
		gravity = 2000
		
		
	# Falling speed limit
	if velocity.y >1500:
		velocity.y = 1500
		
	#wall slide
	if(is_on_wall() and !is_on_floor()):
		if((Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right") or Input.is_action_just_released("ui_left") or Input.is_action_just_released("ui_right")) or abs(Input.get_joy_axis(0,0))> 0.3):
			is_wall_sliding = true
		if is_on_wall():
			is_wall_sliding = true
		
		if(is_wall_sliding==true):
			velocity.y += (wall_slide_gravity * delta)
			velocity.y = min(velocity.y, wall_slide_speed)
	if is_on_wall():
		is_wall_sliding = true
	
	# Moving Left and Right
	var direction = Input.get_axis("ui_left", "ui_right")
	#flip sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h= true
		
	#play animations
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		elif is_wall_sliding == false:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")
	#applies movement
	if direction and can_move:
		velocity.x =  normal_speed * direction
	else:
		velocity.x = move_toward(velocity.x, 0, normal_speed)
	
	if not is_on_floor():
		velocity.y += gravity * delta

	#velocity.x = speed * horiziontal_direction
	#if is_on_floor():
		#sprite.flip.h = (horizontal_direction == -1)
			
	
	
	apply_gravity(delta)
	coyote_jump()
	move_and_slide()
	

	
func animation():
	pass
	
		
	
func ui_lefthold():
	if !Input.is_action_pressed("ui_left"):
		return
func ui_righthold():	
	if !Input.is_action_pressed("ui_right"):
		return	

func Jump():
	if Input.is_action_just_pressed("ui_accept"):
		
		if (is_on_floor() and can_jump) or coyote_jump_timer.time_left > 0.0:
			velocity.y= jump_velocity
			can_jump = false
			
		else:
			jump_buffer.start()
		
		if is_on_floor() and jump_buffer.time_left > 0:
			jump_buffer.stop()
		
			
			#Wall Jump
			
		if is_wall_right():
			velocity=wall_jump_velocity
			velocity.x = -wall_jump_pushback
			can_move = false
			$WallJump.start()
			is_wall_jumping == true
			can_jump = false
			
			
			
			if is_wall_jumping == true:
				gravity = 0
			
		if is_wall_left():
			velocity = wall_jump_velocity
			velocity.x = wall_jump_pushback
			can_move = false
			$WallJump.start()
			is_wall_jumping == true
			can_jump = false
			
			
			if is_wall_jumping == true:
				gravity = 0
			
#Wall jump timera
func _on_wall_jump_timeout():
	gravity = gravity
	can_walljump = false
	is_wall_jumping = false
	can_move = true 

func is_wall_right():
	if $RayCast2D2.get_collider()!=null and not is_on_floor():
		can_walljump= true
	
		return true
	else:
		can_walljump=false
		return false
		
func is_wall_left():
	if $RayCast2D.get_collider()!=null and not is_on_floor():
		can_walljump= true
		return true
	
	else:
		can_walljump=false
		return false
		
func dash():
	
	if Input.is_action_just_pressed("shift") and canDash:
		dashing = true
		canDash = false
		if direction_facing == -1:
			velocity.x = dashspeed
		if direction_facing == 1:
			velocity.x = dashspeed * -1
		
	
	if canDash == false:
		await get_tree().create_timer(1).timeout
		canDash = true
		dashing = false
		 
		
	#while dashing == true: 
		#gravity = 0
	
		


