extends Node3D

@onready var score_label: Label = %Score

var score = 0

func increase_score():
	score += 1
	score_label.text = "Score: " + str(score)

func _on_mob_spawner_3d_mob_spawned(mob: Variant) -> void:
	mob.mob_died.connect(increase_score)
