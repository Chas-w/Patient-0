extends Node3D
@export_category("Puppet Strings")
@export var left_bicep : Node3D
@export var left_forearm : Node3D
@export var right_bicep : Node3D
@export var right_forearm : Node3D
@export var left_knee : Node3D
@export var left_ankle : Node3D
@export var right_knee : Node3D
@export var right_ankle : Node3D

@export_category("Control Categories")
@export var hips : Node3D
@export var torso : Node3D
@export var shoulders : Node3D

@export_category("Movement Constraints")
 ##defaults to true, leads with left foot
@export var left_footed : bool = true
##how far between steps before taking another step
@export_range(1,100,.5) var step_distance_max : float
var step_distance
##how far a control needs to be from the torso to follow suit
@export_range(1,100,.5) var fly_range_max : float 
var fly_range

func _ready():
	step_distance = step_distance_max
	fly_range = fly_range_max
