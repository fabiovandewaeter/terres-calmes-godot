extends RigidBody3D

signal mob_died()

var speed: float = randf_range(2, 4.0)
var health: float = 20.0

@onready var bat_model: Node3D = %bat_model
@onready var player: Node3D = get_node("/root/Game/Player")
@onready var timer: Timer = %Timer

func _physics_process(delta: float) -> void:
	_follow_player()

func _follow_player():
	var direction = global_position.direction_to(player.global_position)
	direction.y = 0.0
	linear_velocity = direction * speed	# IT'S A BAD THINK !!!!!
	bat_model.rotation.y = Vector3.FORWARD.signed_angle_to(direction, Vector3.UP) + deg_to_rad(180)

func take_damage(damages: float):
	if health <= 0.0:
		return
	bat_model.hurt() # animation
	health -= damages
	if health <= 0.0:
		set_physics_process(false)
		gravity_scale = 1.0
		timer.start()
		mob_died.emit()

func _on_timer_timeout() -> void:
	if health <= 0.0:
		queue_free()
