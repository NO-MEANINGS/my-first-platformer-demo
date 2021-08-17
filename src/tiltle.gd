extends Control


onready var audio:AudioStreamPlayer = $AudioStreamPlayer


func _ready():
	randomize()
	$congratulations.visible = GamePass.game_pass
	if GamePass.game_pass:
		audio.stream = preload("res://asset/win.ogg")
		audio.stream.loop = false
		audio.play()
	else:
		audio.stream = preload("res://asset/title.ogg")
		audio.stream.loop = true
		audio.play()
	return


func _process(delta):
	return


func _on_New_pressed():
	get_tree().change_scene("res://sence/testmain.tscn")
	return


func _on_Settings_pressed():
	pass # Replace with function body.


func _on_Exit_pressed():
	get_tree().quit(0)
	return


func _on_Legal_pressed():
	OS.shell_open(ProjectSettings.globalize_path("res://legal_info.txt"))
	return
