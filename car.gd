extends VehicleBody3D

@export var engine_speed : int = 200
@export var steering_speed : float = 0.4
@export var fov : float = 75

@onready var seat = $Seat

var cache = null

# Called when the node enters the scene tree for the first time.
func _ready():
	cache = transform


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if position.y < -50:
		transform = cache
		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO
	var speedkph = (abs(linear_velocity.x)+abs(linear_velocity.y)+abs(linear_velocity.z)) * 3.6
	$CanvasLayer/Control/Speed.text = str(round(speedkph))+" KPH"
	#$Camera3D.fov = lerp($Camera3D.fov,75*(sqrt(speedkph)*0.1 + 1),0.1)
	#$SpringArm3D.spring_length = lerp($SpringArm3D.spring_length,8*(sqrt(speedkph)*0.1 + 1),0.1)
#	if Input.is_action_just_pressed("Respawn"):
#		transform = cache
#		linear_velocity = Vector3.ZERO
#		angular_velocity = Vector3.ZERO
#	if Input.is_action_pressed("flip") and seat.get_child_count() > 0:
#		apply_torque_impulse(Vector3(0,0,-rotation.z)*20)

func _physics_process(delta):
	if seat.get_child_count() > 0:
		controls(lerp(steering,-seat.get_child(0).input_dir.x * steering_speed * delta * 100,0.2),-seat.get_child(0).input_dir.y * engine_speed * delta * 100)
		$BackLeft.wheel_friction_slip = 0.1 if Input.is_action_pressed("sprint") else 10.5
		$BackRight.wheel_friction_slip = 0.1 if Input.is_action_pressed("sprint") else 10.5

@rpc("call_local")
func controls(steer,engine):
	steering = steer
	engine_force = engine
