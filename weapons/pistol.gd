extends Node3D

@export var raycastpath: NodePath 

@onready var raycast = get_node(raycastpath)
@onready var anim_player = $AnimationPlayer
@onready var muzzle_flash = $MuzzleFlash
@onready var mesh = $Cube
@onready var ammo_display = $CanvasLayer/Control/PanelContainer/Ammo
@onready var display = $CanvasLayer/Control
@onready var shellpos = $Shell

var damage = 16
var ammo = 17
var maxammo = 17
var gunshot = preload("res://gunshot.tscn")
var bullet_hole = preload("res://bullet_hole.tscn")
var shells = preload("res://weapons/shells_vector.tscn")

func findByClass(node: Node, className : String, result : Array) -> void:
	if node.is_class(className) :
		result.push_back(node)
	for child in node.get_children():
		findByClass(child, className, result)

# Called when the node enters the scene tree for the first time.
func _ready():
	if multiplayer.get_unique_id()==get_parent().get_parent().get_parent().name.to_int():
		display.visible = true
		var results = []
		findByClass($Model, "MeshInstance3D", results)
		for result in results:
			result.set_layer_mask_value(2, true)
			result.set_layer_mask_value(1, false)
#		mesh.set_layer_mask_value(2, true)
#		mesh.set_layer_mask_value(1, false)
#		var material = mesh.get_surface_override_material(0).duplicate(true)
#		material.no_depth_test = true
#		mesh.set_surface_override_material(0,material)

func play(anim):
	if anim_player.current_animation != "shoot" and anim_player.current_animation != "reload":
		anim_player.play(anim)
func use():
	if $ShootDelay.time_left <= 0 and anim_player.current_animation != "reload" and ammo > 0:
		$ShootDelay.start()
		play_shoot_effects.rpc()
#		play_shoot_effects.rpc()
#		set_ammo(ammo-1)
#		if raycast.is_colliding():
#			if raycast.get_collider().is_in_group("player"):
#				var hit_player = raycast.get_collider()
#				hit_player.recieve_damage.rpc_id(hit_player.get_multiplayer_authority(),damage)
#			else:
#				var bh = bullet_hole.instantiate()
#				bh.position = raycast.get_collision_point()
#				var normal = raycast.get_collision_normal()
#				get_parent().get_parent().get_parent().get_parent().get_node("BulletHoles").add_child(bh, true)
#				if normal != Vector3.UP:
#				# look in the direction of the normal
#					bh.look_at(raycast.get_collision_point() + normal, Vector3.UP)
#				# then look "up" from there so the decal projects "down"
#					bh.transform = bh.transform.rotated_local(Vector3.RIGHT, PI/2.0)
#				bh.rotate(normal, randf_range(0, 2*PI))
func sh():
	var gc = gunshot.instantiate()
	add_child(gc, true)
	muzzle_flash.restart()
	gc.global_position = muzzle_flash.global_position
	set_ammo(ammo-1)
	if raycast.is_colliding():
		if raycast.get_collider().is_in_group("player"):
			var hit_player = raycast.get_collider()
			hit_player.recieve_damage.rpc_id(hit_player.get_multiplayer_authority(),damage)
		else:
			var bh = bullet_hole.instantiate()
			bh.position = raycast.get_collision_point()
			var normal = raycast.get_collision_normal()
			get_parent().get_parent().get_parent().get_parent().get_node("BulletHoles").add_child(bh, true)
			if normal != Vector3.UP:
			# look in the direction of the normal
				bh.look_at(raycast.get_collision_point() + normal, Vector3.UP)
			# then look "up" from there so the decal projects "down"
				bh.transform = bh.transform.rotated_local(Vector3.RIGHT, PI/2.0)
			bh.rotate(normal, randf_range(0, 2*PI))
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
<<<<<<< HEAD
	if get_parent().name != "weapon": return
	if Input.is_action_pressed("sprint") and anim_player.current_animation == "move":
		anim_player.speed_scale = 1.8
	else:
		anim_player.speed_scale = 1
	if anim_player.current_animation == "shoot":
		anim_player.speed_scale = 1
	if (ammo <= 0 or (Input.is_action_just_pressed("reload")) and ammo != maxammo) and anim_player.current_animation != "reload":
=======
	if (ammo <= 0 or (Input.is_action_just_pressed("reload")) and ammo != maxammo) and (anim_player.current_animation != "shoot" and anim_player.current_animation != "reload") and visible:
>>>>>>> 3f533e0e2d5c2a4cf0af85d43e258ad2b77036bb
		anim_player.play("reload")
	if multiplayer.get_unique_id()==get_parent().get_parent().get_parent().name.to_int():
		display.visible = visible
		if Input.is_action_just_pressed("shoot") and visible:
			use()

func set_ammo(amount):
	ammo = amount
	ammo_display.text = str(ammo)

@rpc("call_local")
func play_shoot_effects():
#	var gc = gunshot.instantiate()
#	add_child(gc, true)
#	gc.global_position = muzzle_flash.global_position
	anim_player.stop()
	anim_player.play("shoot")
#	spawnshell()
#	var pc = shells.instantiate()
#	pc.position = shellpos.position
#	add_child(pc)
func spawnshell():
	var pc = shells.instantiate()
	pc.position = shellpos.position
	add_child(pc)

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "shoot":
		anim_player.play("idle")
	if anim_name == "reload":
		anim_player.play("idle")

func reload():
	set_ammo(maxammo)
