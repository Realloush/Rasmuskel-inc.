extends CharacterBody2D

@onready var coyote_jump_timer = $CoyoteJumpTimer
@onready var jump_buffer = $JumpBuffer
@onready var collision = $CollisionShape2D
@onready var bottom_collision_left = $RayCast2D
@onready var bottom_collision_right = $RayCast2D2
@onready var top_collision_left = $RayCast2D4
@onready var top_collision_right = $RayCast2D3
@onready var dash_cooldown = $DashCooldown
@onready var wall_jump_timer = $Wall_jump
@onready var wall_jump_lerp_timer = $WallJumpLerp



#physics 
var gravity = 1800
var friction = 8000.0
var acceleration = 9000.0
var air_resistence = 8000.0
#basic movement var
var can_move = true
var normal_speed = 500.0
var direction_facing = 1
#jump var
var jump_velocity = -1150
var double_jump_velocity = -1150
var can_double_jump = true
#dash var
var can_dash = true
var is_dashing = false 
var dashDirection = Vector2(1, 0)
#walljump var
var is_wall_jumping_right = false
var is_wall_jumping_left = false
var wall_jump_horizontal_speed = 2000.0
var wall_jump_velocity = -1100.0
#WallSliding Var
var is_wall_sliding_right = false
var is_wall_sliding_left = false
var is_wall_sliding = false


func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		
		
	
	

func _process(_delta):
	pass
func handle_dashing():
		# Dash
		
	if Input.is_action_pressed("ui_right"):
		dashDirection = Vector2(1,0)
	if Input.is_action_pressed("ui_left"):
		dashDirection = Vector2(-1,0)
	if Input.is_action_just_pressed("shift") and can_dash:
		is_dashing = true
		velocity += dashDirection.normalized() * 4500
		if is_dashing ==true:
			gravity = 0
		else:
			gravity = 1800
		$DashCooldown.start()
		can_dash = false
		is_dashing = false
func handle_wall_slide():
	
		# Wall Sliding
	if is_on_floor():
		is_wall_sliding_left = false
		is_wall_sliding_right = false
	if is_on_wall_only() and velocity.x > 0:
		is_wall_sliding_right = true
	if is_on_wall_only() and velocity.x < 0:
		is_wall_sliding_left = true
		
	
	
	if not is_on_wall_only():
		is_wall_sliding = false
	if velocity.y >0 and is_wall_sliding_left and not await(handle_dashing()) and bottom_collision_left.is_colliding() and top_collision_left.is_colliding():
		velocity.y = velocity.y * 0.9
		can_double_jump = true
		is_wall_sliding = true
		can_dash = true
		is_wall_jumping_right = false
		is_wall_jumping_left = false
	if velocity.y >0 and is_wall_sliding_right and not await(handle_dashing()) and bottom_collision_right.is_colliding() and top_collision_right.is_colliding():
		velocity.y = velocity.y * 0.9
		can_double_jump = true
		is_wall_sliding = true
		can_dash = true
		is_wall_jumping_right = false
		is_wall_jumping_left = false
func handle_wall_jump():
	
	if not is_on_wall():
		return
	var wall_normal = get_wall_normal()
	if Input.is_action_just_pressed("ui_accept"):
		if is_wall_sliding_right:
			is_wall_jumping_right = true
		elif is_wall_sliding_left:
			is_wall_jumping_left = true
		wall_jump_timer.start()
		#wall_jump_lerp_timer.start()
		velocity.x = wall_normal.x * wall_jump_horizontal_speed
		velocity.y = wall_jump_velocity
		can_move = false


	if wall_jump_timer.time_left != 0: 
		velocity.x = wall_normal.x * wall_jump_horizontal_speed
		if velocity.x < wall_normal.x * wall_jump_horizontal_speed:
			velocity.x = wall_normal.x * wall_jump_horizontal_speed
func coyote_jump():
		# Coyote jump
	var was_on_floor = is_on_floor()
	move_and_slide()
	var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_ledge:
		coyote_jump_timer.start()
func _physics_process(delta):
		
	
	if wall_jump_timer.time_left <= 0:
		wall_jump_timer.stop()
		can_move = true
		is_wall_jumping_left = false
		is_wall_jumping_right = false
	if Input.is_action_just_pressed("ui_right"):
		
		$Sprite2D.flip_h = true
	if Input.is_action_just_pressed("ui_left"):
		
		$Sprite2D.flip_h = false
	# Double Jump
	if Input.is_action_just_pressed("ui_accept") and not is_on_floor() and not is_wall_sliding and can_double_jump and not await(handle_dashing()):
		velocity.y = double_jump_velocity
		can_double_jump = false
		gravity = 2100
		
	if velocity.y <5 and velocity.y > -5:
		gravity = 2100
	# When falling gravity becomes stronger
	if  velocity.y >1 and not is_on_floor():
			gravity = 3000
			
	# Resets gravity when on floor
	if is_on_floor():
		gravity = 2000
		can_double_jump = true
		can_dash = true
	
		
	# Jump height
	if Input.is_action_just_released("ui_accept") and not velocity.y > -30:
		gravity = 9000
		
		
	# Falling speed limit
	if velocity.y >1500:
		velocity.y = 1500
	handle_dashing()
	handle_wall_slide()
	handle_wall_jump()
	
	apply_gravity(delta)
	coyote_jump()
	
		
	
		
	

		
	# Jump and Buffer Jump
	if Input.is_action_just_pressed("ui_accept") and not await(handle_dashing()):
		if is_on_floor() or coyote_jump_timer.time_left > 0.0:
			velocity.y = jump_velocity
		else:
			jump_buffer.start()
		
	if is_on_floor() and jump_buffer.time_left > 0:
		jump_buffer.stop()
	# Moving Left and Right
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction and not await(handle_dashing()) and can_move:
		velocity.x =  normal_speed * direction 
	else:
		velocity.x = move_toward(velocity.x, 0, normal_speed)


  
