extends Node2D


onready var GF:RayCast2D = $GroundDetectorFront
onready var GB:RayCast2D = $GroundDetectorBack
onready var WU:RayCast2D = $WallDetectorUp
onready var WD:RayCast2D = $WallDetectorDown
onready var CF:RayCast2D = $CeilingDetctorFront
onready var CB:RayCast2D = $CeilingDetctorBack
onready var LT:Area2D = $LanternDetector
onready var WOLF_TIMER_LIM:float = get_node("..").WOLF_TIMER_LIM
var gandw:Dictionary = { # ground and wall
	gf = false,
	gb = false,
	wu = false,
	wd = false,
	cf = false,
	cb = false,
}
var _gandw:Dictionary = {}
var on_ground:bool = false
var on_wall:bool = false
var wall_jump_tolerance:int = -1
var in_air:bool = false
var wolf_time:bool = false
var wolf_timer:float = 0.0
var lantern_list:Array = []
var active_lantern


func _physics_process(delta) -> void:
	get_ground_and_wall()
	var last_frame_active_lantern = active_lantern
	
	if (_gandw.gf && !_gandw.gb) && (!gandw.gf && !gandw.gb) && !wolf_time:
		wolf_time = true
	elif wolf_time:
		wolf_timer += delta
		if wolf_timer >= WOLF_TIMER_LIM:
			wolf_time = false
	
	on_ground = gandw.gf || gandw.gb || wolf_time
	var on_wall_old = on_wall
	on_wall = gandw.wu || gandw.wd
	in_air = !(on_ground || on_wall)
	if on_wall: wall_jump_tolerance = 8
	elif (on_wall_old && !on_wall) || (wall_jump_tolerance >= 0): wall_jump_tolerance -= 1
	else: pass
	if (gandw.cb || gandw.cf) && get_parent().velocity.y < 0: 
		get_parent().velocity.y = 0
	### debug 
	#print("on_ground: ", on_ground, "	on_wall: ", on_wall, "	in_air: ", in_air)
	###
	
	var player_facing:Vector2 = Vector2(-1, 0) if (get_parent().face == "left") else Vector2(1, 0)
	var active_lantern_should_be = false
	for lantern in lantern_list:
		var player_to_lantern = lantern.position - get_parent().position
		if get_world_2d().direct_space_state.intersect_ray(get_parent().position, lantern.position, [get_parent(), self], 0b00000000000000000100, true, false): pass
		elif (player_facing.dot(player_to_lantern) >= 0):
			active_lantern_should_be = lantern
	active_lantern = active_lantern_should_be
	if active_lantern:
		active_lantern.get_node("AnimationPlayer").play("idle")
		if last_frame_active_lantern:
			if active_lantern != last_frame_active_lantern:
				last_frame_active_lantern.get_node("AnimationPlayer").stop(false)
	elif last_frame_active_lantern:
		last_frame_active_lantern.get_node("AnimationPlayer").stop(false)
	return


func get_ground_and_wall() -> void:
	_gandw = gandw
	gandw.gf = GF.is_colliding()
	gandw.gb = GB.is_colliding()
	gandw.wu = WU.is_colliding()
	gandw.wd = WD.is_colliding()
	gandw.cf = CF.is_colliding()
	gandw.cb = CB.is_colliding()
	return


func _on_LanternDetector_lantern_entered(lantern):
	lantern_list.append(lantern)
	return


func _on_LanternDetector_lantern_exited(lantern):
	lantern_list.remove(lantern_list.find(lantern))
	return
