extends "res://Scripts/character.gd"

#movement variables
var speed = 2
var jump = 3

#var damage = 100

var mouse_sensitivity = 0.2

var picked_object
var pull_power = 10

var times = 0

@onready var camera = $Head/Camera
@onready var aimcast = $Head/Camera/AimCast
@onready var collider = $CollisionShape
@onready var hand = $Head/Camera/hand

@onready var particlesystem = $GPUParticles3D
@onready var audioplayer = $AudioStreamPlayer
@onready var text = $Head/Camera/pickupcounter

func pick_object():
	var collider1 = aimcast.get_collider()
	if collider1 != null and collider1 is RigidBody3D:
		#pickup
		times += 1
		picked_object = collider1
		particlesystem.set_emitting(true)
		var path = "res://Audio/Audio " + str(randi_range(1, 3)) + ".wav"
		
		if times == 10:
			path = "res://Audio/Audio " + str(4) + ".wav"
		elif times == 50:
			path = "res://Audio/Audio " + str(5) + ".wav"
		elif times == 100:
			path = "res://Audio/Audio " + str(6) + ".wav"
		
		var file
		if FileAccess.file_exists(path):
			file = FileAccess.open(path, FileAccess.READ)
			var buffer = file.get_buffer(file.get_length())
			var stream = AudioStreamWAV.new()
			for i in 200:
				buffer.remove_at(buffer.size()-1) # removes pop sound at the end
				buffer.remove_at(0)
				stream.data = buffer
				stream.format = 1 # 16 bit
				stream.mix_rate = 44100
				stream.stereo = true
				file.close()
			audioplayer.stream = stream
			audioplayer.play()
		
		print("fuck you " + collider1.name)

func drop_object():
	if picked_object != null:
		picked_object = null

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
	if Input.is_action_just_pressed("pause"):
		get_tree().quit()

func _process(delta):
	
	text.clear()
	text.append_text("Times cube has been picked up: " + str(times))
	
	if Input.is_action_just_pressed("interact"):
		if picked_object == null:
			pick_object()
		elif picked_object != null:
			drop_object()
		if aimcast.is_colliding():
			var target = aimcast.get_collider()
			if target.is_in_group("Button"):
				target.activate(delta)

func _physics_process(delta):
	
	calculateGravity(delta)
	
	#Jumping
	if Input.is_action_just_pressed("move_jump") and (is_on_floor() or ground_check.is_colliding()):
		gravity_vec = Vector3.UP * jump

	#Movement
	if Input.is_action_pressed("move_forward"):
		direction -= transform.basis.z
	elif Input.is_action_pressed("move_backwards"):
		direction += transform.basis.z
	if Input.is_action_pressed("move_right"):
		direction += transform.basis.x
	elif Input.is_action_pressed("move_left"):
		direction -= transform.basis.x
	
	if picked_object != null:
		var a = picked_object.global_transform.origin
		var b = hand.global_transform.origin
		picked_object.set_linear_velocity((b-a)*pull_power)
	
	moveCharacter(speed, direction, delta)
	#for i in get_slide_collision_count():
		#if get_slide_collision(0).get_collider().is_in_group("Enemy"):
			#push_warning("get die")
			#get_tree().reload_current_scene()
		#i += 1

