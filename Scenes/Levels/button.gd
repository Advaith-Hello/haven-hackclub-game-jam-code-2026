extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if Globals.box_on_top:
		Globals.move = true
