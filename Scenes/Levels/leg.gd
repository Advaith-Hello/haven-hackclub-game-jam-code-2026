extends CharacterBody2D

var stop = true


func _physics_process(_delta: float) -> void:
	if Globals.move:
		get_tree().change_scene_to_file("res://Scenes/Levels/outro.tscn")
