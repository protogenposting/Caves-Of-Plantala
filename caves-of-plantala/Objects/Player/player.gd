extends CharacterBody2D


const SPEED = 200.0
const JUMP_VELOCITY = -300.0
const ACCELERATION = 50
const FAST_ACCELERATION = 15
const AIR_ACCELERATION = 25
const FAST_AIR_ACCELERATION = 2
const MAX_COYOTE_TIME = 5
const JUMP_WINDOW = 7
const MAX_FALL_SPEED = 1000
const MAX_DASH_TIME = 20
const DASH_TURN_SPEED = 3
const DASH_SPEED = 500

var coyoteTime : int = 0

var jumpTime : int= 0

var dashTimeLeft : int = 0

var canDash : bool = false

var dashVector : Vector2= Vector2(0,0)

var colorTime : int = 0

var facing : int = 1

var startPosition : Vector2

func _ready() -> void:
	startPosition.x = position.x
	startPosition.y = position.y

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		if velocity.y > MAX_FALL_SPEED:
			velocity.y = MAX_FALL_SPEED
	
	coyoteTime -= delta * 60
	
	jumpTime -= delta * 60
	
	colorTime -= delta * 60
	
	# Handle jump.
	if is_on_floor():
		coyoteTime = MAX_COYOTE_TIME
		
		if dashTimeLeft < MAX_DASH_TIME/2 && !canDash:
			colorTime = 10
			canDash = true
	
	if InputBuffer.is_action_press_buffered("Jump") && coyoteTime > 0:
		velocity += get_platform_velocity()
		
		jumpTime = JUMP_WINDOW
		coyoteTime = 0
		
		if dashTimeLeft > 0:
			dashTimeLeft = 0
			velocity.x = DASH_SPEED * sign(velocity.x)
			if dashVector.y > 0:
				velocity.x = DASH_SPEED * 1.5 * sign(velocity.x)
				velocity.y /= 2
	
	if InputBuffer.is_action_press_buffered("Dash") && canDash && dashTimeLeft <= 0:
		var moveVector = get_move_axis()
		
		dashTimeLeft = MAX_DASH_TIME
		
		dashVector = moveVector * DASH_SPEED
		
		print(dashVector.x)
		
		dashVector.x = max(abs(moveVector.x * DASH_SPEED),abs(velocity.x) + 20) * sign(moveVector.x)
		
		print(dashVector.x)
		
		jumpTime = 0
		
		canDash = false
	
	if dashTimeLeft > 0:
		var moveAngle = get_move_axis().angle()
		
		var rotateBy = angle_difference(dashVector.angle(),moveAngle) * delta * 60 * DASH_TURN_SPEED
		
		dashVector = dashVector.rotated(deg_to_rad(rotateBy))
		
		velocity.x = dashVector.x
		
		facing = sign(velocity.x)
		
		if facing == 0:
			facing = 1
		
		velocity.y = dashVector.y
		
		dashTimeLeft -= delta * 60
		
		if dashTimeLeft <= 0:
			if velocity.y <= 0 || is_on_floor():
				velocity.x = DASH_SPEED * 0.8 * dashVector.normalized().x
				velocity.y = DASH_SPEED * 0.8 * dashVector.normalized().y
	
	if jumpTime > 0:
		velocity.y = JUMP_VELOCITY
		if Input.is_action_just_released("Jump"):
			jumpTime = 0
	
	# movement
	var direction := Input.get_axis("Left", "Right")
	
	var accel = ACCELERATION
	
	if abs(velocity.x) > DASH_SPEED:
		accel = FAST_ACCELERATION
	
	if !is_on_floor():
		accel = AIR_ACCELERATION
		if abs(velocity.x) > DASH_SPEED && sign(velocity.x) == sign(direction):
			accel = FAST_AIR_ACCELERATION
	
	if direction && dashTimeLeft <= 0:
		facing = sign(direction)
		velocity.x = move_toward(velocity.x,sign(direction) * SPEED,accel)
	else:
		velocity.x = move_toward(velocity.x, 0, accel)

	$TorchParticles.emitting = canDash
	
	$DashParticles.emitting = dashTimeLeft > 0
	
	$Control/Speed.text = "Speed: "+str(velocity.x)
	
	$Sprite.scale.x = facing
	
	print(get_real_velocity())

	move_and_slide()

func freeze(time):
	Engine.time_scale = 0
	await get_tree().create_timer(time,true,false,true).timeout
	Engine.time_scale = 1

func get_move_axis() -> Vector2:
	var moveVector = Input.get_vector("Left", "Right","Up","Down")
	
	moveVector.x = round(moveVector.x)
	
	moveVector.y = round(moveVector.y)
	
	return moveVector.normalized()

func angle_difference(angle1, angle2) -> float:
	var diff = angle2 - angle1
	return diff if abs(diff) < 180 else diff + (360 * -sign(diff))

func die():
	position = startPosition


func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Kill"):
		die()
		velocity = Vector2(0,0)
		canDash = false
		coyoteTime
	pass # Replace with function body.
