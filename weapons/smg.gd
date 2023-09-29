extends Node3D

@export var raycastpath: NodePath 
@onready var raycast = get_node(raycastpath)
@onready var anim_player = $AnimationPlayer
@onready var muzzle_flash = $MuzzleFlash
@onready var mesh = $Cube
@onready var ammo_display = $CanvasLayer/Control/PanelContainer/Ammo
@onready var display = $CanvasLayer/Control
@onready var shellpos = $Shell

var damage = 10
var ammo = 30
var maxammo = 30
var gunshot = preload("res://gunshot.tscn")
var gunshotsound = preload("res://assets/audio/smg1_fire1.wav")
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
#		for i in range(mesh.get_surface_override_material_count()): 
#			var material = mesh.get_active_material(i).duplicate(true)
#			material.no_depth_test = true
#			mesh.set_surface_override_material(i,material)

func play(anim):
	if anim_player.current_animation != "shoot" and anim_player.current_animation != "reload":
		anim_player.play(anim)
func use():
	if anim_player.current_animation != "shoot" and anim_player.current_animation != "reload" and ammo > 0 :
		play_shoot_effects.rpc()
		set_ammo(ammo-1)
		if raycast.is_colliding():
			if raycast.get_collider().is_in_group("player"):
				var hit_player = raycast.get_collider()
				hit_player.recieve_damage.rpc_id(hit_player.get_multiplayer_authority(),damage)
			elif raycast.get_collider().is_in_group("structure"):
				var hit = raycast.get_collider().get_parent()
				hit.recieve_damage.rpc(damage)
			else:
				var bh = bullet_hole.instantiate()
				bh.position = raycast.get_collision_point()
				var normal = raycast.get_collision_normal()
				get_tree().get_root().get_node("World").get_node("BulletHoles").add_child(bh, true)
				if normal != Vector3.UP:
				# look in the direction of the normal
					bh.look_at(raycast.get_collision_point() + normal, Vector3.UP)
				# then look "up" from there so the decal projects "down"
					bh.transform = bh.transform.rotated_local(Vector3.RIGHT, PI/2.0)
				bh.rotate(normal, randf_range(0, 2*PI))
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_pressed("sprint") and anim_player.current_animation == "move":
		anim_player.speed_scale = 1.8
	else:
		anim_player.speed_scale = 1
	if anim_player.current_animation == "shoot":
		anim_player.speed_scale = 1
	if ((ammo <= 0 or (Input.is_action_just_pressed("reload")) and ammo != maxammo) and anim_player.current_animation != "reload") and visible:
		anim_player.play("reload")
	if multiplayer.get_unique_id()==get_parent().get_parent().get_parent().name.to_int():
		display.visible = visible
		if Input.is_action_pressed("shoot") and visible: # change for auto and semi auto
			use()
func set_ammo(amount):
	ammo = amount
	ammo_display.text = str(ammo)

@rpc("call_local")
func play_shoot_effects():
	var gc = gunshot.instantiate()
	gc.get_node('Gunshot').stream = gunshotsound
	add_child(gc, true)
	gc.global_position = muzzle_flash.global_position
	anim_player.stop()
	anim_player.play("shoot")
	muzzle_flash.restart()
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
