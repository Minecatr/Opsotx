extends CharacterBody3D

signal health_changed(health_value)
signal money_changed(money_value)

@export var selected_weapon = 0

@onready var camera = $Camera3D
@onready var gun_camera = $Camera3D/SubViewportContainer/SubViewport/GunCam
@onready var raycast = $Camera3D/RayCast3D
@onready var weapon = $Camera3D/weapon

var health = 100
var menu = false
var money = 1000

const MOUSE_SENSITIVITY = 0.0025
const JUMP_VELOCITY = 8.0
const ACCELERATION = 10.0
const AIR_RESISTANCE = 2.0
const WALK_SPEED = 5
const RUN_SPEED = 9

# Get the gravity from the project settings to be synced with RigidBody nodes.

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

func _ready():
	if not is_multiplayer_authority(): return
	position = Vector3(randf()-0.5,5,randf()-0.5)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.current = true
	if multiplayer.get_unique_id()==name.to_int():
		$Camera3D/SubViewportContainer.visible = true

func _unhandled_input(event):
	if not is_multiplayer_authority(): return
	
	if Input.is_action_just_pressed("menu"):
		menu = !menu
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if menu else Input.MOUSE_MODE_CAPTURED
	
	if not menu:
		if event is InputEventMouseMotion:
			rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
			camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
			camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)

func _physics_process(delta):
	if not is_multiplayer_authority(): return
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	if position.y < -50:
		position = Vector3(randf()-0.5,5,randf()-0.5)
	
	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor() and !menu:
		velocity.y = JUMP_VELOCITY

	var speed = RUN_SPEED if Input.is_action_pressed("sprint") else WALK_SPEED

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Vector2.ZERO
	if !menu:
		input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	#direction = direction.rotated(Vector3.UP, $SpringArm3D.rotation.y).normalized()
	if is_on_floor():
		velocity.x = lerp(velocity.x, direction.x * speed, delta * ACCELERATION)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * ACCELERATION)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * AIR_RESISTANCE)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * AIR_RESISTANCE)
	
	if !weapon.get_child(selected_weapon):
		pass
	elif input_dir != Vector2.ZERO and is_on_floor():
		weapon.get_child(selected_weapon).play("move")
	else:
		weapon.get_child(selected_weapon).play("idle")
	move_and_slide()

func _process(_delta):
	if multiplayer.get_unique_id()==name.to_int():
		gun_camera.global_transform = camera.global_transform
		for n in range(1,10): # Hotbar
			if Input.is_action_just_pressed(str(n)) and n <= weapon.get_child_count():
				selected_weapon = n-1
				equip.rpc()
	else:
		equip()

@rpc("call_local")
func equip():
	for w in weapon.get_children():
		w.visible = false
	weapon.get_child(selected_weapon).visible = true
@rpc("any_peer")
func recieve_damage(damage):
	health -= damage
	if health <= 0:
		health = 100
		position = Vector3(randf()-0.5,5,randf()-0.5)
	health_changed.emit(health)

@rpc("call_local")
func change_money(amt):
	money += amt
	if multiplayer.get_unique_id()==name.to_int():
		get_parent().get_node("CanvasLayer/HUD/Label").text = "$"+str(money)
