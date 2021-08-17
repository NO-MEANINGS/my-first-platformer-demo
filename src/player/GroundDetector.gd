extends RayCast2D


func _on_Player_face_changed() -> void:
	position.x *= -1
	return
