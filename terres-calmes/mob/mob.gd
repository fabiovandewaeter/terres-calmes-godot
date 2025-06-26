extends RigidBody3D

var speed: float = randf_range(2, 4.0)

@onready var bat_model: Node3D = %bat_model
@onready var player: Node3D = get_node("/root/Game/Player")

func _physics_process(delta: float) -> void:
	_follow_player()

func _follow_player():
	var direction = global_position.direction_to(player.global_position)
	direction.y = 0.0
	linear_velocity = direction * speed	# IT'S A BAD THINK !!!!!
	bat_model.rotation.y = Vector3.FORWARD.signed_angle_to(direction, Vector3.UP) + deg_to_rad(180)

func take_damage():
	bat_model.hurt()
