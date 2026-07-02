extends CharacterBody3D
#https://www.youtube.com/watch?v=A3HLeyaBCq4 
@export_category("Player Data Info")
var status_dictionary
var inventory_dictionary
@export var health : float
@export var morality : float
@export var gun : MeshInstance3D
var database

var speed
var input_dir 
var direction 
const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 4.8
const SENSITIVITY = 0.04

#fov variables
const DEFAULT_FOV = 75.0
const ZOOM_FOV = 50
const SPRINT_FOV = 100

@export_group("Camera")
@export var default_cam : PhantomCamera3D
@export var zoom_cam : PhantomCamera3D
@export var cam_origin : Node3D
@export var cam : Camera3D
@export var cam_follow_weight : float
var zoomed : bool

@export_group("States")
enum Move_State{Idle,Moving,Null}
@export var move_state : Move_State = Move_State.Idle
enum Interact_State{Talk,Threaten, Inspect, Attack, In_Menu, Null}
@export var interact_state : Interact_State = Interact_State.Null

func _unhandled_input(event):
	#Camera && Player rotation
	if (event is InputEventMouseMotion):
		rotate_y(deg_to_rad(-event.relative.x * SENSITIVITY))
		cam_origin.rotate_x(deg_to_rad(-event.relative.y * SENSITIVITY))
		cam_origin.rotation.x = clamp(cam_origin.rotation.x, deg_to_rad(-90), deg_to_rad(45))

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	input_dir = Input.get_vector("left", "right", "up", "down")
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	for game_obj in get_tree().get_nodes_in_group("Database"): #assign database
		database = game_obj
	status_dictionary = database._JSON_to_dictionary(database.player_status_path)
	inventory_dictionary = database._JSON_to_dictionary(database.player_inventory_path)
	health = status_dictionary.Health
	morality = status_dictionary.Morality

func _process(delta):
	input_dir = Input.get_vector("left", "right", "up", "down")
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if (Input.is_action_just_pressed("gun")):
		inventory_dictionary.Permanent.Gun.Active = !inventory_dictionary.Permanent.Gun.Active
		gun.visible = !gun.visible
	_handle_zoom(delta)
		
	if(direction && move_state != Move_State.Moving):
		_set_move_state(Move_State.Moving)

func _physics_process(delta):
	match(move_state):
		Move_State.Moving:
			_handle_movement(delta)

func _handle_zoom(delta):
	if(Input.is_action_pressed("zoom")):
		if (inventory_dictionary.Permanent.Gun.Active && interact_state != Interact_State.Threaten):
			zoom_cam.priority = 10
			default_cam.priority = 0
			_set_interact_state(Interact_State.Threaten)
		cam.fov = lerpf(cam.fov, ZOOM_FOV, delta * 2)
		if(!zoomed):
			zoomed = true
	else:
		if (interact_state == Interact_State.Threaten):
			zoom_cam.priority = 0
			default_cam.priority = 10
			_set_interact_state(Interact_State.Null)
		cam.fov = lerpf(cam.fov, DEFAULT_FOV, delta * 2)
		if(zoomed):
			zoomed = false

func _handle_movement(delta):
#region Movement
# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if (!zoomed):
		# Handle jump.
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		# Handle Sprint.
		if Input.is_action_pressed("sprint"):
			speed = SPRINT_SPEED
		else:
			speed = WALK_SPEED
	# Get the input direction and handle the movement/deceleration.
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
	
	move_and_slide()
#endregion

func _set_move_state(next_move_state:int):
	var prev_move_state := move_state
	move_state = next_move_state
		
	#check last state
	match(prev_move_state):
		pass
	#check upcoming state
	match(next_move_state):
		Move_State.Moving:
			pass

func _set_interact_state(next_interact_state:int):
	var prev_interact_state := interact_state
	interact_state = next_interact_state
		
	#check last state
	match(prev_interact_state):
		Interact_State.Threaten:
			pass
	#check upcoming state
	match(next_interact_state):
		Interact_State.Threaten:
			pass


func _update_JSON_data():
	status_dictionary.Health = health
	status_dictionary.Morality = morality
	
	status_dictionary.Position[0] = global_position.x
	status_dictionary.Position[1] = global_position.y
	status_dictionary.Position[2] = global_position.z
	
	database._save_JSON_file(database.player_status_path, status_dictionary)
	database._save_JSON_file(database.player_inventory_path, inventory_dictionary)
