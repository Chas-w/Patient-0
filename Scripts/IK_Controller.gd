extends Node3D
@export_category("Movement")
@export var character_body : CharacterBody3D


@export_category("Puppet Strings")
@export var left_bicep : Marker3D
@export var left_forearm : Marker3D
@export var right_bicep : Marker3D
@export var right_forearm : Marker3D
@export var left_knee : Marker3D
@export var left_ankle : Marker3D
@export var right_knee : Marker3D
@export var right_ankle : Marker3D

@export_category("Control Categories")
@export var all_limbs_and_checkers : Array[Marker3D]
@export var hips : Marker3D
@export var torso : Marker3D
@export var shoulders : Marker3D

@export_category("Movement Constraints")
 ##defaults to true, leads with left foot
@export var left_footed : bool = true
##how far between steps before taking another step
@export_range(1,100,.5) var step_distance_max : float
var step_distance
##how far a control needs to be from the torso to follow suit
@export_range(1,100,.5) var fly_range_max : float 
var fly_range

@export_category("Raycasts")
@export var step_left : RayCast3D
@export var step_right : RayCast3D
var ready_for_step : bool

func _ready():
	step_distance = step_distance_max
	fly_range = fly_range_max
	

func _process(delta):
	pass
	torso.global_position = character_body.global_position
	torso.rotation = character_body.global_rotation

func _step_checker():
	if(step_left.get_collider().is_in_group("Ground")):
		pass
	else: 
		return
