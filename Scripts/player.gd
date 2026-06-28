extends CharacterBody3D
#https://www.youtube.com/watch?v=A3HLeyaBCq4 

var speed
const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 4.8
const SENSITIVITY = 0.04

#bob variables
const BOB_FREQ = 2
const BOB_AMP = 0.03
var t_bob = 0.0

#fov variables
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

@export var cam_origin : Node3D
@export var cam : Camera3D
@export var cam_follow_weight : float

func _unhandled_input(event):
	if (event is InputEventMouseMotion):
		rotate_y(deg_to_rad(-event.relative.x * SENSITIVITY))
		cam_origin.rotate_x(deg_to_rad(-event.relative.y * SENSITIVITY))
		cam_origin.rotation.x = clamp(cam_origin.rotation.x, deg_to_rad(-90), deg_to_rad(45))


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _process(delta):
	pass


func _physics_process(delta):
# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Handle Sprint.
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z  * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)
	#
	## FOV
	#var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	#var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	#cam.fov = lerp(cam.fov, target_fov, delta * 8.0)
	move_and_slide()
