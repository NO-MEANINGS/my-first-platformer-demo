extends Camera2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var fixed_cam = Camera2D.new()


# Called when the node enters the scene tree for the first time.
func _ready():
	fixed_cam.name = "fixed_cam"
	return


func _on_level_changed(new_level):
	if new_level.is_big_level:
		make_current()
	else:
		if !get_node_or_null("/root/Camera2D"):
			get_node("/root").add_child(fixed_cam)
		fixed_cam.make_current()
		fixed_cam.transform = Transform2D(Vector2(1,0), Vector2(1,0), new_level.position + Vector2(510,300))
		current = false
	return
