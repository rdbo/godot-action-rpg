extends Area2D

signal invincibility_started
signal invincibility_ended

export(bool) var show_effect = true
const HIT_EFFECT = preload("res://Effects/HitEffect.tscn")
onready var timer = $Invincibility
var invincible = false setget set_invincible

func set_invincible(value):
	invincible = value
	if invincible:
		start_invincibility()
	else:
		stop_invincibility()

func start_invincibility():
	# Disable 'Monitorable' collision
	self.set_deferred("monitorable", false)
	timer.start()
	emit_signal("invincibility_started")

func stop_invincibility():
	# Enable 'Monitorable' collision (triggers _on_area_entered again)
	monitorable = true
	emit_signal("invincibility_ended")

func _on_Hurtbox_area_entered(_area):
	self.start_invincibility()
	
	if not show_effect:
		return
	
	var effect = HIT_EFFECT.instance()
	effect.global_position = self.global_position
	var main = get_tree().current_scene
	main.add_child(effect)


func _on_Timer_timeout():
	self.stop_invincibility()
