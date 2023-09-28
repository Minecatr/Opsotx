extends TextureButton

@export var bounds : Vector3 = Vector3.ONE
@export var cost : int = 10
# Called when the node enters the scene tree for the first time.
func _ready():
	$Label.text = str(cost)
	var c = load("res://structures/"+name+".tscn").instantiate()
	$SubViewport/Camera3D.position = c.get_node("Properties").camerapos
	$SubViewport.add_child(c)
	texture_normal = $SubViewport.get_texture()
	texture_hover = $SubViewport.get_texture()
	texture_pressed = $SubViewport.get_texture()
	texture_click_mask = $SubViewport.get_texture()
func _pressed():
	if button_pressed == false:
		get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().select({"name"="","cost"=0})
	else:
		get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().select(self)
	for child3 in get_parent().get_parent().get_parent().get_children():
		for child2 in child3.get_children():
			for child in child2.get_children():
				if child != self:
					child.button_pressed = false
