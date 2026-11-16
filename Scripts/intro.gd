extends Node2D

@export var tohere: String = ''

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VideoStreamPlayer.play()
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().change_scene_to_file(tohere)


func _on_video_stream_player_finished() -> void:
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file(tohere)
