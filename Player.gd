extends CharacterBody3D

signal health_changed(health_value)

@onready var camera = $Camera3D
@onready var animationplayer = $AnimationPlayer
@onready var muzzle_flash = $Camera3D/pistol/MuzzleFlash
@onready var raycast = $Camera3D/RayCast3D

var health = 100
var menu = false

const MOUSE_SENSITIVITY = 0.0025
const SPEED = 5.0
const JUMP_VELOCITY = 8.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gunshot = preload("res://gunshot.tscn")
var bullet_hole = preload("res://bullet_hole.tscn")
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

func _ready():
	if not is_multiplayer_authority(): return
	position = Vector3(randf()-0.5,5,randf()-0.5)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.current = true

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
		if Input.is_action_just_pressed("shoot") and animationplayer.current_animation != "shoot":
			play_shoot_effects.rpc()
			if raycast.is_colliding():
				if raycast.get_collider().is_in_group("player"):
					var hit_player = raycast.get_collider()
					hit_player.recieve_damage.rpc_id(hit_player.get_multiplayer_authority(),25)
				else:
					var bh = bullet_hole.instantiate()
					bh.position = raycast.get_collision_point()
					var normal = raycast.get_collision_normal()
					get_parent().get_node("BulletHoles").add_child(bh, true)
					if normal != Vector3.UP:
					# look in the direction of the normal
						bh.look_at(raycast.get_collision_point() + normal, Vector3.UP)
					# then look "up" from there so the decal projects "down"
						bh.transform = bh.transform.rotated_local(Vector3.RIGHT, PI/2.0)
					bh.rotate(normal, randf_range(0, 2*PI))

func _physics_process(delta):
	if not is_multiplayer_authority(): return
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	if not menu:
		# Handle Jump.
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var input_dir = Input.get_vector("left", "right", "forward", "backward")
		var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
		if animationplayer.current_animation == "shoot":
			pass
		elif input_dir != Vector2.ZERO and is_on_floor():
			animationplayer.play("move")
		else:
			animationplayer.play("idle")

	move_and_slide()
@rpc("call_local")
func play_shoot_effects():
	var gc = gunshot.instantiate()
	add_child(gc)
	gc.global_position = muzzle_flash.global_position
	animationplayer.stop()
	animationplayer.play("shoot")
	muzzle_flash.restart()

@rpc("any_peer")
func recieve_damage(damage):
	health -= damage
	if health <= 0:
		health = 100
		position = Vector3(randf()-0.5,5,randf()-0.5)
	health_changed.emit(health)

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "shoot":
		animationplayer.play("idle")
