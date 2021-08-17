extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Flag_body_entered(body):
	if body is Player:
		GamePass.game_pass = true
		get_tree().change_scene("res://sence/tiltle.tscn")
		get_tree().root.get_node("./fixed_cam").queue_free()
	return
