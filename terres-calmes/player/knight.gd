extends Node3D

@onready var animation_player: AnimationPlayer = %AnimationPlayer

func hurt():
	animation_player.play("Hit_A")

func attack():
	animation_player.play("1H_Melee_Attack_Chop")
