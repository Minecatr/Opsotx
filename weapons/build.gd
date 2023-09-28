extends Node3D

@onready var display = $CanvasLayer/Control
@onready var structureplacer = $StructurePlacer
@onready var buildmenu = $CanvasLayer/Control/Menu

var selected : String = ""
var selected_cost : int
var selected_size : Vector3 = Vector3.ONE
var selected_rotation : Vector3 = Vector3.ZERO

var money = 99999
var snap = Vector3(0.5,0.5,0.5)
#func findByClass(node: Node, className : String, result : Array) -> void:
#	if node.is_class(className) :
#		result.push_back(node)
#	for child in node.get_children():
#		findByClass(child, className, result)

# Called when the node enters the scene tree for the first time.
func _ready():
	if multiplayer.get_unique_id()==get_parent().get_parent().get_parent().name.to_int():
		display.visible = true
		var results = []

func play(anim):
	pass
#	if anim_player.current_animation != "shoot" and anim_player.current_animation != "reload":
#		anim_player.play(anim)

func buildpos(delta):
	var camera = get_parent().get_parent()
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_length = 8
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * ray_length
	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	ray_query.collide_with_bodies = true
	ray_query.collide_with_areas = false
	var raycast_result = space.intersect_ray(ray_query)
	if raycast_result:
		structureplacer.visible = true
		structureplacer.global_position = lerp(structureplacer.global_position,(raycast_result.position+(raycast_result.normal*(selected_size/2))).snapped(snap),delta*64)
		structureplacer.global_rotation = Vector3.ZERO + selected_rotation
	else:
		structureplacer.visible = false

func _process(delta):
	if multiplayer.get_unique_id()==get_parent().get_parent().get_parent().name.to_int():
		display.visible = visible
		if visible:
			buildpos(delta)
			if !get_parent().get_parent().get_parent().menu:
				if Input.is_action_just_pressed("shoot"):
					use()
				if Input.is_action_just_pressed("aim"):
					destroy()
				if Input.is_action_just_pressed("reload"):
					selected_rotation.y = wrapf(selected_rotation.y+PI/2,-PI,PI)
					print(structureplacer.rotation)
			if Input.is_action_just_pressed("modify"):
				buildmenu.visible = !buildmenu.visible
				get_parent().get_parent().get_parent().menu = buildmenu.visible
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if buildmenu.visible else Input.MOUSE_MODE_CAPTURED
			if Input.is_action_just_pressed("menu"):
				buildmenu.visible = false
		elif buildmenu.visible:
			buildmenu.visible = false
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func destroy():
	var camera = get_parent().get_parent()
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_length = 8
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * ray_length
	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	ray_query.collide_with_bodies = true
	ray_query.collide_with_areas = false
	var raycast_result = space.intersect_ray(ray_query)
	if raycast_result.collider.get_parent().get_node_or_null("Properties") and raycast_result.collider.get_parent().get_node_or_null("Properties").placer == get_parent().get_parent().get_parent():
		raycast_result.collider.get_parent().queue_free()
func use():
	if structureplacer.visible == true and Input.is_action_just_pressed("shoot") and selected != "" and selected_cost <= money:
		place.rpc(selected,(structureplacer.global_position).snapped(snap), structureplacer.global_rotation)
		#place.rpc(selected,round(structureplacer.global_position))
# Called every frame. 'delta' is the elapsed time since the previous frame.

@rpc("call_local")
func place(s,pos,rot):
	var c = load("res://structures/"+s+".tscn").instantiate()
	c.position = pos
	c.rotation = rot
	c.get_node("Properties").placer = get_parent().get_parent().get_parent()
	# change_points(-selected_cost,0,0)
	get_parent().get_parent().get_parent().get_parent().get_node("PlayerStructures").add_child(c,true)

func select(structure):
	selected = structure.name
	selected_cost = structure.cost
	selected_size = structure.bounds
	for c in structureplacer.get_children():
			c.queue_free()
	if selected != "":
		var currentstructure = load("res://Structures/"+selected+".tscn").instantiate()
		for collider in currentstructure.get_node("Properties").collisions:
			currentstructure.get_node("Properties").get_node(collider).queue_free()
		for c in currentstructure.get_children():
			if c.is_in_group("build"):
				c.material_override = load("res://assets/selected.tres")
		structureplacer.add_child(currentstructure)
