extends Area2D


signal player_touched_spike


func _on_spike_body_entered(body):
	if body is Player: emit_signal("player_touched_spike")
	return
