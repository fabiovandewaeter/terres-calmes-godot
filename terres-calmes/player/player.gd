extends CharacterBody3D

const SPEED = 5.5
const JUMP_HEIGHT = 10.0
const GRAVITY = 30.0

@onready var pivot = $CameraOrigin
@onready var sens: float  = 0.5

func _ready():
	Input.mouse_mode	= Input.MOUSE_MODE_CAPTURED
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sens))
		pivot.rotate_x(deg_to_rad(-event.relative.y * sens))
		pivot.rotation.x = clamp(pivot.rotation.x, deg_to_rad(-90), deg_to_rad(45))

func _physics_process(delta: float) -> void:
	# movements
	var input_direction_2D = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var input_direction_3D = Vector3(input_direction_2D.x, 0.0, input_direction_2D.y)
	var direction = transform.basis * input_direction_3D
	
	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED
	
	# jump
	velocity.y -= GRAVITY * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_HEIGHT
	elif Input.is_action_just_released("jump") and velocity.y > 0.0:
		# allow shorter jumps
		velocity.y *= 0.5
	
	move_and_slide()
	
	if Input.is_action_pressed("shoot") and %ShootingCooldown.is_stopped():
		shoot_bullet()
	
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

func shoot_bullet():
	const BULLET_3D = preload("res://player/bullet_3d.tscn")
	var new_bullet = BULLET_3D.instantiate()
	%Marker3D.add_child(new_bullet)
	
	new_bullet.global_transform = %Marker3D.global_transform
	%ShootingCooldown.start()
