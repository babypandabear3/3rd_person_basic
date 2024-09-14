extends Node3D

@export var player_path : NodePath
@export var mouse_sensitivity := 0.01
@export var camera_x_min := -45.0
@export var camera_x_max := 45.0

var player : Player

@onready var axis_y: Node3D = $Axis_Y
@onready var spring_arm_3d: SpringArm3D = $Axis_Y/SpringArm3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_node_or_null(player_path)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera_x_min = deg_to_rad(camera_x_min)
	camera_x_max = deg_to_rad(camera_x_max)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	if not player:
		player = get_node_or_null(player_path)
		return
		
	player.camera_axis_y_basis = axis_y.global_basis
	global_position = player.global_position
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		axis_y.rotation.y = wrapf(axis_y.rotation.y - event.relative.x * mouse_sensitivity, -PI, PI)
		spring_arm_3d.rotation.x = clamp(spring_arm_3d.rotation.x - event.relative.y * mouse_sensitivity, camera_x_min, camera_x_max)
		
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
