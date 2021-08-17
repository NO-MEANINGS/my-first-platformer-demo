extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var m:bool = true
var j:bool = true
var p:bool = true
var kwj:bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	$move.visible = true
	$jump.visible = false
	$pull.visible = true
	return


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if m && (Input.is_action_pressed("left") || Input.is_action_pressed("right")):
		m = false
		$move.visible = false && m
	if j && Input.is_action_just_pressed("jump"):
		j = false
		$jump.visible = false && j
	
	if !(m || j || p): self.queue_free()
	
	return


func _on_jumparea_body_entered(_body):
	$jump.visible = true && j
	return


func _on_Player_pull_started():
	$pull.visible =false
	p = false
	return


func _on_Area2D_body_entered(body):
	if !$kick_wall_jump/RichTextLabel2.visible:
		$kick_wall_jump/RichTextLabel1.visible = true
	return


func _on_Area2D2_body_entered(body):
	if !$kick_wall_jump/RichTextLabel1.visible:
		$kick_wall_jump/RichTextLabel2.visible = true
	return


func _on_Area2D3_body_entered(body):
	$kick_wall_jump/RichTextLabel3.visible = true
	return


func _on_Area2D4_body_entered(body):
	$kick_wall_jump/RichTextLabel4.visible = true
	return


func _on_Player_wall_jump_learned():
	if kwj:
		$kick_wall_jump.visible = false
		kwj = !kwj
	return
