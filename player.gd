class_name Player
extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 6.0

enum STATES{
	WALK,
	HANGING,
	CLIMB_UP
}

var state : STATES = STATES.WALK

var camera_axis_y_basis : Basis

@onready var body_model: MeshInstance3D = $body_model
@onready var ray_1: RayCast3D = $body_model/ray1
@onready var ray_2: RayCast3D = $body_model/ray2
@onready var ray_3: RayCast3D = $body_model/ray3

#variables for climbing up
var climb_point1 : Vector3
var climb_point2 : Vector3

func _physics_process(delta: float) -> void:
	match state:
		STATES.WALK:
			do_walk(delta)
		STATES.HANGING:
			do_hanging(delta)
		STATES.CLIMB_UP:
			do_climb_up(delta)
	
func do_walk(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (camera_axis_y_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	if velocity.length() > 0.5:
		body_model.global_basis = camera_axis_y_basis
		
	move_and_slide()
	
	if not is_on_floor() and ray_1.is_colliding() and not ray_2.is_colliding() and ray_3.is_colliding():
		state = STATES.HANGING
		var normal = ray_1.get_collision_normal()
		body_model.global_basis = Basis.looking_at(-normal)
		var body_pos = global_position
		var colpos = ray_3.get_collision_point()
		var fix = colpos.y - body_pos.y - 0.75 # 0.75 is height difference between ray_3 and hand position
		global_position.y += fix

func do_hanging(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		state = STATES.CLIMB_UP
		var colpos = ray_3.get_collision_point()
		climb_point1 = global_position
		climb_point1.y = colpos.y + 1
		climb_point2 = colpos
		climb_point2.y += 1
		velocity = Vector3.ZERO
		var tween = create_tween()
		tween.tween_property(self, "global_position", climb_point1, 0.5)
		tween.tween_property(self, "global_position", climb_point2, 0.5)
		tween.finished.connect(_tween_finished)
	pass
	
func do_climb_up(_delta):
	pass

func _tween_finished():
	state = STATES.WALK
