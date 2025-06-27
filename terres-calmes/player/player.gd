extends CharacterBody3D

const JUMP_HEIGHT: float = 10.0
const GRAVITY: float = 30.0
const MIN_ZOOM: int = 0
const MAX_ZOOM: int = 20

@export_group("Camera")
@export_range(0.0, 1.0) var mouse_sensitivity = 0.005
@export_group("Movement")
@export var move_speed = 5.5
@export var acceleration = 20.0
@export var rotation_speed = 12.0
@export var stopping_speed := 1.0

@onready var camera_pivot: Node3D = %CameraPivot
@onready var camera_3d: Camera3D = %Camera3D
@onready var mesh_instance_3d: MeshInstance3D = %MeshInstance3D
@onready var spring_arm_3d: SpringArm3D = %SpringArm3D

var _last_movement_direction: Vector3 = Vector3.BACK

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent):
	if event.is_action_pressed("left_click"):
		Input.mouse_mode	 = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _unhandled_input(event: InputEvent) -> void:
	var is_camera_motion = event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	if is_camera_motion:
		camera_pivot.rotation.y -= event.relative.x * mouse_sensitivity
		camera_pivot.rotation.x -= event.relative.y * mouse_sensitivity
		camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, deg_to_rad(-90), deg_to_rad(45))
	if Input.is_action_just_pressed("wheel_up") and spring_arm_3d.spring_length > MIN_ZOOM:
		spring_arm_3d.spring_length -= 1
	if Input.is_action_just_pressed("wheel_down") and spring_arm_3d.spring_length < MAX_ZOOM:
		spring_arm_3d.spring_length += 1
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

func _physics_process(delta: float) -> void:
	# movements
	var input_direction_2D = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var forward = camera_3d.global_basis.z
	var right = camera_3d.global_basis.x
	var move_direction = forward * input_direction_2D.y + right * input_direction_2D.x
	move_direction.y = 0.0
	move_direction = move_direction.normalized()
	velocity = velocity.move_toward(move_direction * move_speed, acceleration * delta)
	
	# jump
	velocity.y -= GRAVITY * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_HEIGHT
	elif Input.is_action_just_released("jump") and velocity.y > 0.0:
		# allow shorter jumps
		velocity.y *= 0.5
	
	if is_equal_approx(move_direction.length(), 0.0) and velocity.length() < stopping_speed:
		velocity.x = 0.0
		velocity.z = 0.0
	
	move_and_slide()
	
	# turn player when movement
	var is_aiming = Input.is_action_pressed("right_click")
	if move_direction.length() > 0.2 and not is_aiming:
		_last_movement_direction = move_direction
		var target_angle = Vector3.FORWARD.signed_angle_to(_last_movement_direction, Vector3.UP)
		mesh_instance_3d.global_rotation.y = lerp_angle(mesh_instance_3d.global_rotation.y, target_angle, rotation_speed * delta)
	elif is_aiming:	# if aiming
		var cam_dir = -camera_3d.global_transform.basis.z
		cam_dir.y = 0
		cam_dir = cam_dir.normalized()
		var target_angle = Vector3.FORWARD.signed_angle_to(cam_dir, Vector3.UP)
		mesh_instance_3d.global_rotation.y = target_angle
	
	if Input.is_action_pressed("shoot") and %ShootingCooldown.is_stopped():
		shoot_bullet()

func shoot_bullet():
	const BULLET_3D = preload("res://player/bullet_3d.tscn")
	var new_bullet = BULLET_3D.instantiate()
	%Marker3D.add_child(new_bullet)
	
	new_bullet.global_transform = %Marker3D.global_transform
	%ShootingCooldown.start()
