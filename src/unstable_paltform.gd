extends Node2D


var start:Vector2
var end:Vector2
onready var tilemap:TileMap = get_node("../../../Map/ground_and_wall/s4m_ur4i_huge-assetpack-tilemap")


func _ready():
	get_node("./Area2D/CollisionShape2D").shape.extents = get_node("./StaticBody2D/CollisionShape2D").shape.extents + Vector2(0, 0.5)
	get_node("./Area2D").position += Vector2(0, 0.5)
	start = position + Vector2(-24, 0)
	end = position + Vector2(12, 0)
	return


func _on_Area2D_body_entered(body):
	if body is Player: $collapse_timer.start()
	return


func _on_collapse_timer_timeout():
	$recovery_timer.start()
	$StaticBody2D/CollisionShape2D.disabled = true
	$Area2D/CollisionShape2D.disabled = true
	for i in range(start.x / 12, end.x / 12 + 1):
		for j in range(start.y / 12, end.y / 12 + 1):
			print(tilemap.get_cell(i, j))
			tilemap.set_cell(i, j, -1)
	return


func _on_recovery_timer_timeout():
	$StaticBody2D/CollisionShape2D.disabled = false
	$Area2D/CollisionShape2D.disabled = false
	for i in range(start.x / 12, end.x / 12 + 1):
		for j in range(start.y / 12, end.y / 12 + 1):
			#print(tilemap.get_cell(i, j))
			tilemap.set_cell(i, j, 1)
	return
