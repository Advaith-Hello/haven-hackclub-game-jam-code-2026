extends Area2D

var dontStick = false

func _ready() -> void:
	$"../../Music/CozyOne".play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	
	if dontStick:
		global_position.y = Globals.player_pos.y - 900.0
		global_position.x = Globals.player_pos.x - 2400.0

func _on_body_entered(_body: Node2D) -> void:
	dontStick = true
	Globals.box_on_top = true
	
	
