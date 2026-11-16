extends CharacterBody2D


const SPEED = 1000.0
const JUMP_VELOCITY = -1000.0

var collidingPlayer = false


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		$AnimatedSprite2D.play("Walk")
	
	if is_on_wall():
		velocity.y = JUMP_VELOCITY
	
	var direction = global_position.direction_to(Globals.player_pos)
	$AnimatedSprite2D.flip_h = sign(direction.x) == -1
	velocity.x += SPEED * direction.x * delta
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider.is_in_group("Player"):
			collidingPlayer = true
	
	if collidingPlayer:
		get_tree().change_scene_to_file("res://Scenes/Levels/Level1.tscn")
	
	move_and_slide()
