extends Area2D


export var type:int # see Player.pull_lock


func _ready():
#	var idle_anim = $AnimationPlayer.get_animation("idle")
#	idle_anim.add_track(Animation.TYPE_VALUE)
#	$AnimationPlayer.play("idle")
	return


func _process(_delta):
	return


func _on_Area2D_body_entered(body):
	if body is Player:
		#if body.pull_distination_lantern is bool: return
		if body.pull_distination_lantern == self && body.pull_lock ==1:
			body.pull_lock = 0
			body.emit_signal("pull_down")
	return


func _on_Area2D_body_exited(body):
	if body is Player:
		#if body.pull_distination_lantern is bool: return
		if body.pull_distination_lantern == self && body.pull_lock ==1:
			body.pull_lock = 0
			body.emit_signal("pull_down")
	return
