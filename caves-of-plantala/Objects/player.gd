extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -300.0
const ACCELERATION = 50
const MAX_COYOTE_TIME = 5
const JUMP_WINDOW = 7
const MAX_FALL_SPEED = 1000

var coyoteTime = 0

var jumpTime = 0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		if velocity.y > MAX_FALL_SPEED:
			velocity.y = MAX_FALL_SPEED
	
	coyoteTime -= delta * 60
	
	jumpTime -= delta * 60
	
	# Handle jump.
	if is_on_floor():
		coyoteTime = MAX_COYOTE_TIME
	
	if Input.is_action_just_pressed("Jump") && coyoteTime > 0:
		jumpTime = JUMP_WINDOW
		coyoteTime = 0
	
	if jumpTime > 0:
		velocity.y = JUMP_VELOCITY
		if Input.is_action_just_released("Jump"):
			jumpTime = 0

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("Left", "Right")
	if direction:
		velocity.x = move_toward(velocity.x,direction * SPEED,ACCELERATION)
	else:
		velocity.x = move_toward(velocity.x, 0, ACCELERATION)

	move_and_slide()
