extends VehicleBody3D

@export var engine_speed : int = 200
@export var steering_speed : float = 0.4
@export var fov : float = 75

@onready var seat = $Seat
@onready var properties = $Properties

var cache = null

@export var health = 200

@rpc("call_local")
func recieve_damage(damage):
	health -= damage
	if health <= 0:
		if seat.get_child_count() > 0:
			seat.get_child(0).exit_vehicle.rpc()
		queue_free()

# Called when the node enters the scene tree for the first time.
func _ready():
	cache = transform

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if position.y < -50:
		recieve_damage.rpc(health)
	var speedkph = (abs(linear_velocity.x)+abs(linear_velocity.y)+abs(linear_velocity.z)) * 3.6
	$CanvasLayer/Control/Speed.text = str(round(speedkph))+" KPH"
	if freeze and properties.placer:
		freeze = false
