extends CharacterBody2D


const SPEED = 200.0
const JUMP_VELOCITY = -300.0
const ACCELERATION = 50
const FAST_ACCELERATION = 15
const AIR_ACCELERATION = 25
const FAST_AIR_ACCELERATION = 4
const MAX_COYOTE_TIME = 5
const JUMP_WINDOW = 7
const MAX_FALL_SPEED = 1000
const MAX_DASH_TIME = 20
const DASH_TURN_SPEED = 3
const DASH_SPEED = 500
const MAX_STAMINA = 100

var coyoteTime : int = 0

var jumpTime : int= 0

var dashTimeLeft : int = 0

var jumpButtonTimer : int = 0

var canDash : bool = false

var dashVector : Vector2= Vector2(0,0)

var colorTime : int = 0

var facing : int = 1

var startPosition : Vector2

var canUltra : bool = false

var climbedLastFrame : bool = false

var lastWall : int = 0

var stamina = 0

func _ready() -> void:
	startPosition.x = global_position.x
	startPosition.y = global_position.y

func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("Left", "Right")
	
	if Input.is_action_just_pressed("Jump"):
		jumpButtonTimer = 5
	
	if not is_on_floor():
		'''if climbedLastFrame:
			velocity.x = lastWall * SPEED
			climbedLastFrame = false
			velocity.y = JUMP_VELOCITY'''
		velocity += get_gravity() * delta
		if velocity.y > MAX_FALL_SPEED:
			velocity.y = MAX_FALL_SPEED
	
	var cameraAreas = $Hurtbox.get_overlapping_areas()
	
	var touching : Area2D = null
	
	for i in cameraAreas:
		if i.is_in_group("CameraArea"):
			touching = i
			break
	
	if touching != null:
		var cameraCollision : CollisionShape2D = touching.get_node("Shape")
		
		var cameraShape : RectangleShape2D = cameraCollision.shape
		
		$Camera2D.limit_left = touching.position.x - touching.scale.x * cameraShape.size.x / 2
		
		$Camera2D.limit_right = touching.position.x + touching.scale.x * cameraShape.size.x / 2
		
		$Camera2D.limit_top = touching.position.y - touching.scale.y * cameraShape.size.y / 2
		
		$Camera2D.limit_bottom = touching.position.y + touching.scale.y * cameraShape.size.y / 2
	else:
		die()
		$Camera2D.limit_left = -10000000
		$Camera2D.limit_top = -10000000
		$Camera2D.limit_right = 10000000
		$Camera2D.limit_bottom = 10000000
	
	coyoteTime -= delta * 60
	
	jumpTime -= delta * 60
	
	colorTime -= delta * 60
	
	jumpButtonTimer -= delta * 60
	
	var wallDirection = int($RightWall.is_colliding()) - int($LeftWall.is_colliding())
	
	climbedLastFrame = false
	
	if wallDirection != 0 && !is_on_floor():
		if Input.is_action_pressed("Grab") && stamina > 0 && jumpTime <= 0:
			velocity.y = 0
			
			stamina -= delta * 10
			
			if Input.is_action_pressed("Up"):
				velocity.y = JUMP_VELOCITY/4
				stamina -= delta * 10
				climbedLastFrame = true
				lastWall = wallDirection
			if Input.is_action_pressed("Down"):
				velocity.y = MAX_FALL_SPEED/10
			if jumpButtonTimer > 0:
				jumpTime = JUMP_WINDOW
				jumpButtonTimer = 0
				stamina -= 30
		else:
			if jumpButtonTimer > 0:
				if direction != 0:
					velocity.x = -wallDirection * SPEED * 2
				else:
					velocity.x = -wallDirection * SPEED * 1.25
				jumpTime = JUMP_WINDOW
				jumpButtonTimer = 0
				if dashTimeLeft > 0 && dashVector.x == 0 && dashVector.y < 0:
					jumpTime = 0
					velocity.y = JUMP_VELOCITY*3
					dashTimeLeft = 0
	
	# Handle jump.
	if is_on_floor():
		stamina = MAX_STAMINA
		coyoteTime = MAX_COYOTE_TIME
		
		if dashTimeLeft < MAX_DASH_TIME/2 && !canDash:
			colorTime = 10
			canDash = true
	
	
	if jumpButtonTimer > 0 && coyoteTime > 0:
		jumpTime = JUMP_WINDOW
		coyoteTime = 0
		jumpButtonTimer = 0
		
		if canUltra:
			velocity.x *= 1.2
			print("ultra!")
			canUltra = false
		
		if dashTimeLeft > 0:
			dashTimeLeft = 0
			velocity.x = DASH_SPEED * sign(velocity.x)
			if dashVector.y > 0:
				velocity.x = DASH_SPEED * 1.5 * sign(velocity.x)
				velocity.y /= 2
		
		velocity += get_platform_velocity()/2
	
	if Input.is_action_just_pressed("Dash") && canDash && dashTimeLeft <= 0:
		var moveVector = get_move_axis()
		
		dashTimeLeft = MAX_DASH_TIME
		
		dashVector = moveVector * DASH_SPEED
		
		dashVector.x = max(abs(moveVector.x * DASH_SPEED),abs(velocity.x) + 20) * sign(moveVector.x)
		
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
			else:
				canUltra = true
	
	if jumpTime > 0:
		velocity.y = JUMP_VELOCITY
		if Input.is_action_just_released("Jump"):
			jumpTime = 0
	
	var accel = ACCELERATION
	
	if abs(velocity.x) >= DASH_SPEED * 0.9  && sign(velocity.x) == sign(direction):
		accel = FAST_ACCELERATION
	
	if !is_on_floor():
		accel = AIR_ACCELERATION
		if abs(velocity.x) > DASH_SPEED * 0.9 && sign(velocity.x) == sign(direction):
			accel = FAST_AIR_ACCELERATION
	elif abs(velocity.x) < DASH_SPEED * 0.9:
		canUltra = false
	
	if direction && dashTimeLeft <= 0:
		facing = sign(direction)
		velocity.x = move_toward(velocity.x,sign(direction) * SPEED,accel)
	else:
		velocity.x = move_toward(velocity.x, 0, accel)

	$TorchParticles.emitting = canDash
	
	$DashParticles.emitting = dashTimeLeft > 0
	
	$DashParticles.scale.x = facing
	
	$Sprite.scale.x = facing
	
	if stamina < MAX_STAMINA:
		$StaminaRect.size.x = 54 * (stamina/MAX_STAMINA)
		
		$StaminaRect.visible = true
	else:
		$StaminaRect.visible = false
	
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
	stamina = 0
	global_position = startPosition
	canUltra = false
	canDash = false
	dashTimeLeft = 0
	jumpTime = 0
	velocity = Vector2(0,0)
	canDash = false
	coyoteTime = 0


func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Kill"):
		die()
	if area.is_in_group("CameraArea") && area.spawn != area:
		startPosition = area.spawn.global_position
	if area.is_in_group("Shroom"):
		canDash = true
		if dashTimeLeft > 0:
			dashVector *= -2
		else:
			velocity.y = JUMP_VELOCITY * 3
	pass # Replace with function body.
