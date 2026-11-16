extends CharacterBody2D

const MAXHEIGHT = 50
var direction = 1
var currHeight = 0

func _ready() -> void:
	$"../Music/SneakingSong".play()

func _physics_process(delta: float) -> void:
	if currHeight >= MAXHEIGHT: 
		direction *= -1
		currHeight = 0
	
	position.y += direction * delta * 50
	currHeight += 1
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider.is_in_group("Player"):
			get_tree().change_scene_to_file("res://Scenes/Levels/getArm.tscn")
	
	move_and_slide()
	
