extends AnimationPlayer


onready var Spt:Sprite = $"../Sprite"
onready var Py:Player = $".."
onready var Detc:Node = $"../Detectors"


func _process(_delta) -> void:
	
	
	if Py.rorl[-1]  == "idle":
		play("idle")
	else:
		play("run")
	
	return


func _on_Player_face_changed() -> void:
	Spt.flip_h = !Spt.flip_h
	return
