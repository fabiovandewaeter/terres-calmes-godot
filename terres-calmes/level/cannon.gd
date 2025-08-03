extends Node3D

func _physics_process(delta: float) -> void:
	if %ShootingCooldown.is_stopped():
		shoot_bullet()

func shoot_bullet():
	const BULLET_3D = preload("res://player/bullet_3d.tscn")
	var new_bullet = BULLET_3D.instantiate()
	%Cannon.add_child(new_bullet)
	
	new_bullet.global_transform = %Cannon.global_transform
	%ShootingCooldown.start()
