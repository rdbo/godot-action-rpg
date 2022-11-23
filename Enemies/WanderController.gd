extends Node2D

signal wander_changed

export(int) var wander_radius = 16
onready var start_position = global_position
onready var wander_position = start_position

func _ready():
	randomize() # Generate random seed
	update_wander_position()

func update_wander_position():
	wander_position = start_position + Vector2(rand_range(-wander_radius, wander_radius), rand_range(-wander_radius, wander_radius))
	emit_signal("wander_changed")


func _on_Timer_timeout():
	update_wander_position()
