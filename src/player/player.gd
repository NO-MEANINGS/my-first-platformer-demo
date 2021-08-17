class_name Player
extends KinematicBody2D


const PULL_COOLDOWN = 0.5
const MAX_FALLING_SPEED:float = 512.0
const WALL_FALLING_SPEED:float = MAX_FALLING_SPEED / 2
const FAST_FALLING_SPEED:float = MAX_FALLING_SPEED * 2 # player can press down when falling to fall down faster
const GRAVITY_ACCELERATION:float = MAX_FALLING_SPEED / 0.2 # MAX_FALLING_SPEED/time
const AIR_FRICTION_ACCELERATION:float = (FAST_FALLING_SPEED - MAX_FALLING_SPEED) / 0.25
const WALL_FRICTION_ACCELERATION:float = GRAVITY_ACCELERATION * 0.5
const WOLF_TIMER_LIM = 0.64
const JUMP_INIT_SPEED = Vector2(0, -512 - 256)
#const JUMP_INIT_SPEED_WALL = Vector2(512 * cos(PI / 3 + PI / 12), -512 * sin(PI / 3 + PI / 12))
const JUMP_INIT_SPEED_WALL = Vector2(2.5 * 512 * cos(PI / 3), -512 * 2.5 * sin(PI / 3))
const PULL_INIT_SPEED = 1024 * 1.5
const MAX_RUNNING_SPEED:float = 256.0
const RUNNING_ACCELERATION:float = MAX_RUNNING_SPEED / 0.15 # MAX_RUNNING_SPEED/time


signal face_changed
signal pull_started
signal pull_down
signal wall_jump_learned


onready var Detc = $Detectors


var inputs:Dictionary = {}
var instructions:Array = []
var velocity:Vector2 = Vector2.ZERO

var rorl:Array = ["idle"] # Right OR Left
var face:String = "right" # used and only used to determine Sprite.flip_h
var jumping = false
var wall_jumping = 0
var pull_lock:int = 0 # 0=no_lock, 1=lock_entill_arrive, 2=lock_based_on_frame
var pull_init_distance:Vector2
var pull_distination_lantern
var pull_lock_two_frame_count:int = 0

var frame_count:int = 0 # for debug
var jump_wall_timer:float = 0.0
var debug_mark:bool = false
#var velocity__ = Vector2.ZERO


func _ready() -> void:
	#Engine.time_scale = 0.5
	#$PullCooldown.start()
	return


func _physics_process(delta) -> void:
	inputs = get_inputs()
	
	# #debug#
	# print(frame_count)
	# for k in inputs:
	# 	if k == "right_just_pressed" || k == "right_just_released" || k == "left_just_pressed" || k == "left_just_released":
	# 		if inputs[k]:
	# 			print(k)
	# frame_count += 1
	# #######
	if debug_mark:
		#inputs.jump = true
		__print_inputs()

	update_face_and_rorl()   
	update_instructions()
	update_velocity(delta)
	
	var _foo = move_and_slide(velocity)
	#var _foo = move_and_slide(velocity__)

	frame_count += 1
	return


func get_inputs() -> Dictionary:
	return {
	jump = Input.is_action_pressed("jump"),
	jump_just_pressed = Input.is_action_just_pressed("jump"),
	jump_just_released = Input.is_action_just_released("jump"),
	right = Input.is_action_pressed("right"),
	right_just_pressed = Input.is_action_just_pressed("right"),
	right_just_released = Input.is_action_just_released("right"),
	left = Input.is_action_pressed("left"),
	left_just_pressed = Input.is_action_just_pressed("left"),
	left_just_released = Input.is_action_just_released("left"),
	up = Input.is_action_pressed("up"),
	down = Input.is_action_pressed("down"),
	pull = Input.is_action_pressed("pull"),
	pull_just_pressed = Input.is_action_just_pressed("pull"),
	pull_just_released = Input.is_action_just_released("pull"),
	}


# update face and emit signal face_changed if face was changed
func update_face_and_rorl() -> void:
	assert(rorl.size() <= 3, "Player.rorl > 3!")
	if inputs.right_just_pressed && inputs.left_just_pressed:
		rorl = ["idle"]
	elif inputs.right_just_pressed:
		rorl.append("right")
	elif inputs.left_just_pressed:
		rorl.append("left")
	
	if inputs.right_just_released && inputs.left_just_released:
		rorl = ["idle"]
	elif inputs.right_just_released:
		var i = rorl.find("right")
		if i != -1:
			rorl.remove(i)
	elif inputs.left_just_released:
		var i = rorl.find("left")
		if i != -1:
			rorl.remove(i)
	
	if rorl[-1] == "idle":
		pass
	elif rorl[-1] != face:
		face = rorl[-1]
		emit_signal("face_changed")
	
	return


func update_instructions() -> void:
	var last_frame_instructions = instructions
	instructions = []
	
	#fall
	#print((!Detc.on_ground && !Detc.on_wall), "  ", (!Detc.on_ground && Detc.on_wall && (rorl[-1] == "idle")))
	if (!Detc.on_ground && !Detc.on_wall) || (!Detc.on_ground && Detc.on_wall && (rorl[-1] == "idle")):
		if !inputs.down:
			instructions.append("fall.regular")
		else:
			instructions.append("fall.fast")
	elif (!Detc.on_ground && Detc.on_wall && (face == rorl[-1])):
		instructions.append("fall.wall")
	elif ("fall.regular" in last_frame_instructions) || ("fall.fast" in last_frame_instructions) || ("fall.wall" in last_frame_instructions):
		instructions.append("fall.end")
	
	#jump
	if Detc.on_ground:
		if inputs.jump_just_pressed:
			jumping = true
			instructions.append("jump.ground")
	elif Detc.on_wall:
		if inputs.jump_just_pressed:
			#wall_jumping = 1
			instructions.append("jump.wall")
			emit_signal("wall_jump_learned")
			get_tree().root.get_node("./Node2D/Node2D").kwj = true
	elif Detc.wall_jump_tolerance >= 0:
		if inputs.jump_just_pressed:
			#wall_jumping = 1
			instructions.append("jump.wall.tolerance")
			emit_signal("wall_jump_learned")
			get_tree().root.get_node("./Node2D/Node2D").kwj = true
	if inputs.jump_just_released:
		if jumping:
			instructions.append("jump.interrupted")
			jumping = false
		elif wall_jumping == 1 || wall_jumping == 2:
			instructions.append("jump.interrupted")
			wall_jumping = 0
	
	if inputs.pull_just_pressed && pull_lock == 0:
		instructions.append("pull")
	
	return


func update_velocity(delta) -> void:
	var velocity_old = velocity
	# fall
	if pull_lock == 1 || pull_lock == 2: pass
	elif "fall.regular" in instructions:
		if velocity.y < MAX_FALLING_SPEED:
			velocity.y += delta * GRAVITY_ACCELERATION
			if velocity.y > MAX_FALLING_SPEED:
				velocity.y = MAX_FALLING_SPEED
		elif velocity.y > MAX_FALLING_SPEED:
			velocity.y -= delta * AIR_FRICTION_ACCELERATION
			if velocity.y < MAX_FALLING_SPEED:
				velocity.y = MAX_FALLING_SPEED
	elif "fall.fast" in instructions:
		if velocity.y < FAST_FALLING_SPEED:
			velocity.y += delta * GRAVITY_ACCELERATION
			if velocity.y > FAST_FALLING_SPEED:
				velocity.y = FAST_FALLING_SPEED
		elif velocity.y > FAST_FALLING_SPEED:
			velocity.y -= delta * AIR_FRICTION_ACCELERATION
			if velocity.y < FAST_FALLING_SPEED:
				velocity.y = FAST_FALLING_SPEED
	elif "fall.wall" in instructions:
		if velocity.y < 0:
			velocity.y += delta * (GRAVITY_ACCELERATION + WALL_FRICTION_ACCELERATION)
		elif velocity.y < WALL_FALLING_SPEED:
			velocity.y += delta * (GRAVITY_ACCELERATION - WALL_FRICTION_ACCELERATION)
			if velocity.y > WALL_FALLING_SPEED:
				velocity.y = WALL_FALLING_SPEED
		elif velocity.y > WALL_FALLING_SPEED:
			velocity.y -= delta * (AIR_FRICTION_ACCELERATION + WALL_FRICTION_ACCELERATION)
			if velocity.y < WALL_FALLING_SPEED:
				velocity.y = WALL_FALLING_SPEED
	elif "fall.end" in instructions:
		velocity.y = 0.0
	
	#if "pull" in instructions: pass
	if "jump.ground" in instructions:
		velocity += JUMP_INIT_SPEED
	elif "jump.wall" in instructions:
		velocity.y = 0
		velocity += JUMP_INIT_SPEED
		if rorl[-1] == "idle": velocity.x = -1.5 * MAX_RUNNING_SPEED if face == "right" else 1.5 * MAX_RUNNING_SPEED
		elif rorl[-1] == face: 
			velocity.x = -2 * MAX_RUNNING_SPEED if face == "right" else 2 * MAX_RUNNING_SPEED
			if (inputs.right_just_pressed || inputs.left_just_pressed) && inputs.jump_just_pressed:
				velocity.x *= -1
	elif "jump.wall.tolerance" in instructions:
		velocity.y = 0
		velocity += JUMP_INIT_SPEED
		velocity.x = -MAX_RUNNING_SPEED if face == "left" else MAX_RUNNING_SPEED
	elif wall_jumping == 1: # "wall"
		velocity = velocity_old - 2 * delta * AIR_FRICTION_ACCELERATION * velocity_old.normalized()
		if velocity.y >= -128: wall_jumping = 2
	elif wall_jumping == 2:
		if velocity_old.x > 0: velocity.x = velocity_old.x - 2 * delta * AIR_FRICTION_ACCELERATION
		else: velocity.x = velocity_old.x + 2 * delta * AIR_FRICTION_ACCELERATION
		velocity.y = -128
		if velocity.x * velocity_old.x <= 0:
			wall_jumping = 0
			velocity.x = 0
	elif "jump.interrupted" in instructions:
		velocity.y /= 2
	
	if pull_lock == 1:
		if (velocity_old.length() >= (PULL_INIT_SPEED / 3.0)):
			velocity = velocity_old.normalized() * PULL_INIT_SPEED\
				* pow(0.966, ((pull_init_distance.length() - (pull_distination_lantern.position - self.position).length()) * (32 / pull_init_distance.length())))
		else:
			velocity = velocity_old.normalized() * PULL_INIT_SPEED / 3.0
		#print(pow(0.966, ((pull_distination_lantern.position - self.position).length() * (32 / pull_init_distance.length()))))
	elif pull_lock == 2:
		pull_lock_two_frame_count += 1
		if pull_lock_two_frame_count > 4:
			pull_lock_two_frame_count = 0
			velocity *= 0.4
			pull_lock = 0
			emit_signal("pull_down")
	if ("pull" in instructions) && Detc.active_lantern:
		pull_distination_lantern = Detc.active_lantern
		pull_init_distance = Detc.active_lantern.position - self.position
		var pull_direction:Vector2 = pull_init_distance.normalized()
		# velocity.y = velocity.y if (velocity.y * pull_direction.y >= 0) else 0.0
		# velocity.x = velocity.x if (velocity.x * pull_direction.x >= 0) else 0.0
		velocity = Vector2.ZERO
		velocity += pull_direction * PULL_INIT_SPEED
		velocity = pull_direction * velocity.length()
		pull_lock = 1 if Detc.active_lantern.type == 1 else 2
		emit_signal("pull_started")

	
	# run
	### if rorl[-1] == "idle":
	#if wall_jumping == 1: pass
	if pull_lock == 1 || pull_lock == 2: pass
	elif rorl[-1] == "idle":
		var a:Vector2 = Vector2(RUNNING_ACCELERATION, 0) if (velocity.x < 0) else Vector2(-RUNNING_ACCELERATION, 0)
		var sign_of_velocity_x = sign(velocity.x)
		velocity += a * delta
		if velocity.x * sign_of_velocity_x <= 0:
			velocity.x = 0.0
	else:
		var direction:Vector2 = Vector2(-1, 0) if (rorl[-1] == "left") else Vector2(1, 0)
		if (abs(velocity.x) <= MAX_RUNNING_SPEED) || (velocity.x * direction.x < 0):
			velocity += direction * RUNNING_ACCELERATION * delta
		else:
			velocity -= direction * AIR_FRICTION_ACCELERATION * delta
	
	return


func respawn():
	for level in get_node("/root/Node2D/levels").get_children():
		if level.overlaps_body(self): 
			print("true")
			position = level.spawn_point
			velocity = Vector2.ZERO
			pull_lock = 0
	return


#func apply_gravity(delta) -> void:
#	return
func __print_inputs() -> void:
	print("--------------- frame=", frame_count)
	for k in inputs:
		print(k, " = ", inputs[k])
