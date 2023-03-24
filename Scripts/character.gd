extends CharacterBody3D

var h_acceleration = 6
var air_acceleration = 1
var normal_acceleration = 6
var gravity = 20
var full_contact = false

var direction = Vector3()
var h_velocity = Vector3()
var movement = Vector3()
var gravity_vec = Vector3()

@onready var head = $Head
@onready var ground_check = $GroundCheck


func calculateGravity(delta):
	#Check if colliding
	if ground_check.is_colliding():
		full_contact = true
	else:
		full_contact = false
	
	#Gravity or smth
	if not is_on_floor():
		gravity_vec += Vector3.DOWN * gravity * delta
		h_acceleration = air_acceleration
	elif is_on_floor() and full_contact:
		gravity_vec = -get_floor_normal() * gravity
		h_acceleration = normal_acceleration
	else:
		gravity_vec = -get_floor_normal()
		h_acceleration = normal_acceleration
	

func moveCharacter(speed, characterDirection, delta):
	direction = Vector3()
	
	#Stuff idk DONT FUCKING TOUCH IF YOU TOUCH IT BREAK
	characterDirection = characterDirection.normalized()
	h_velocity = h_velocity.lerp(characterDirection * speed, h_acceleration * delta)
	movement.z = h_velocity.z + gravity_vec.z
	movement.x = h_velocity.x + gravity_vec.x
	movement.y = gravity_vec.y
	
	#Move
	set_velocity(movement * speed)
	move_and_slide()
