extends CharacterBody2D


# Global

@export var state = "ARM"

# Jumping

const JUMP_PREORDER_MAX = 0.3

var jump_vel = 0.0
var jump_preorder = JUMP_PREORDER_MAX

# HEAD

@onready var head_anim_ground_sprite: AnimatedSprite2D = $Head/GroundAnimSprite
@onready var head_anim_air_sprite: AnimatedSprite2D = $Head/AirAnimSprite
@onready var head_raycast: RayCast2D = $Head/RayCast2D

const HEAD_ROTATION_VEL   = 1e80
const HEAD_ROTATION_MAX   = 10.0
const HEAD_ROT_LERP_PARAM = 0.6

const HEAD_MOVEMENT_VEL   = 1e80
const HEAD_MOVEMENT_MAX   = 1000.0
const HEAD_MOV_LERP_PARAM = 0.6

const HEAD_JUMP_VEL = 0.0

var head_rotation_velocity := 0.0
var head_rotation := rotation
var head_anim_sprite_frame := 0
var head_rot_dir := 0.0

# ARM

@onready var arm_anim_sprite: AnimatedSprite2D = $Arm/AnimatedSprite2D
@onready var arm_raycast: RayCast2D = $Arm/RayCast2D

const ARM_BODY_MOVEMENT_TIME = 0.5
const ARM_BODY_MOVEMENT_DIST = 160.0

const ARM_LAUNCH_VEL = 1200.0
const ARM_LAUNCH_MAX = 600.0

var arm_moving     := 0
var arm_move_timer := 0.0

var is_grappling   := false
var grapple_angle  := 0.0

# Must be dynamic type dont ask why
var arm_curr_frame  = 0

# LEGS

@onready var legs_anim_sprite = $Legs/AnimatedSprite2D
@onready var legs_raycast = $Legs/RayCast2D

const LEGS_MOVEMENT_VEL   = 1e80
const LEGS_MOVEMENT_MAX   = 1000.0
const LEGS_MOV_LERP_PARAM = 0.6
const LEGS_JUMP_VEL = -600.0



# Physics

func _physics_process(delta: float) -> void:
	
	Globals.player_state = state
	
	Globals.player_pos = global_position
	
	# Add the gravity. :slimley:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if state == "HEAD":
		
		$Arm.hide()
		$Legs.hide()
		$LegsCollisionShape.disabled = true
		
		# Animation
		
		head_rotation += head_rotation_velocity * delta
		head_anim_sprite_frame = int(
			16 * fposmod((head_rotation + PI), TAU) / TAU)
		
		if head_raycast.is_colliding():
			head_anim_air_sprite.hide()
			head_anim_ground_sprite.show()
			head_anim_ground_sprite.frame = head_anim_sprite_frame
		else:
			head_anim_ground_sprite.hide()
			head_anim_air_sprite.show()
			head_anim_air_sprite.frame = head_anim_sprite_frame
		
		# Movement
		
		var direction := Input.get_axis("left", "right")
		
		# Unintelligable nonsense pls dont touch
		
		if direction:
			
			if head_raycast.is_colliding():
				head_rot_dir = direction
			
			head_rotation_velocity += head_rot_dir * HEAD_ROTATION_VEL * delta
			head_rotation_velocity = (head_rot_dir * 
				min(abs(head_rotation_velocity), HEAD_ROTATION_MAX))
			
			velocity.x += direction * HEAD_MOVEMENT_VEL * delta
			velocity.x = (direction * 
				min(abs(velocity.x), HEAD_MOVEMENT_MAX))
			
		else:
			head_rotation_velocity = lerp(head_rotation_velocity, 0.0, HEAD_ROT_LERP_PARAM)
			velocity.x = lerp(velocity.x, 0.0, HEAD_MOV_LERP_PARAM)
		
		# One time set
		
		jump_vel = HEAD_JUMP_VEL
	
	elif state == "ARM":
		
		$Head.hide()
		$Legs.hide()
		$LegsCollisionShape.disabled = true
		
		# Movement
		if is_on_wall():
			velocity.y = -600.0
		
		if not arm_moving and Input.is_action_pressed("up"):
			is_grappling = true
		else:
			velocity.x = 0.0
			is_grappling = false
		
		if not is_grappling:
			
			if not arm_moving:
				arm_move_timer = 0.0
				arm_moving = int(Input.get_axis("left", "right"))
			
			if arm_moving:
				
				arm_curr_frame = arm_move_timer / ARM_BODY_MOVEMENT_TIME
				arm_curr_frame = int(arm_curr_frame * 8)
				arm_curr_frame = clampi(arm_curr_frame, 0, 7) % 7
				
				arm_anim_sprite.frame  = arm_curr_frame
				arm_anim_sprite.flip_h = arm_moving == -1
				
				position.x += (ARM_BODY_MOVEMENT_DIST * delta * 
					arm_moving / ARM_BODY_MOVEMENT_TIME)
				
				if (arm_move_timer > ARM_BODY_MOVEMENT_TIME 
					or not (arm_raycast.is_colliding() or is_on_floor())):
					arm_moving = 0
				else:
					arm_move_timer += delta
		
		else:
			
			var node = find_nearest_arm_latch_node()
			var direction = node.direction_to(global_position)
			velocity -= direction * 100.0 * delta
	
	if state == "LEGS":

		$Head.hide()
		$Arm.hide()

		# Movement

		var direction := Input.get_axis("left", "right")

		legs_anim_sprite.frame  = int(abs(global_position.x) / 80) % 8

		if direction:

			legs_anim_sprite.flip_h = direction == -1

			velocity.x += direction * LEGS_MOVEMENT_VEL * delta
			velocity.x = (direction *
			min(abs(velocity.x), LEGS_MOVEMENT_MAX))

		else:
			velocity.x = lerp(velocity.x, 0.0, LEGS_MOV_LERP_PARAM)

		jump_vel = LEGS_JUMP_VEL
	
	# Jumping
	
	if state != "ARM":
	
		if Input.is_action_just_pressed("up"):
			jump_preorder = 0.0
		
		if jump_preorder < JUMP_PREORDER_MAX:
			jump_preorder += delta
		
		if ((state == "HEAD" and head_raycast.is_colliding()) or
		(state == "LEGS" and legs_raycast.is_colliding()) and
		jump_preorder < JUMP_PREORDER_MAX):
			velocity.y = jump_vel
	
	move_and_slide()


func find_nearest_arm_latch_node() -> Vector2:
	var nearest = Vector2.INF
	for pos in Globals.arm_nodes:
		var dist1 = pos.distance_squared_to(global_position)
		var dist2 = nearest.distance_squared_to(global_position)
		if dist1 < dist2: nearest = pos
	return nearest
