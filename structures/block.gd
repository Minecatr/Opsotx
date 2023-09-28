extends Node3D

@export var health = 50

@rpc("call_local")
func recieve_damage(damage):
	health -= damage
	if health <= 0:
		queue_free()
