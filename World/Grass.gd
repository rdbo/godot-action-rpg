extends Node2D

const grass_effect_scene = preload("res://Effects/GrassEffect.tscn")

func create_grass_effect():
	var grass_effect = grass_effect_scene.instance()
	grass_effect.position = self.position
	self.get_parent().add_child(grass_effect)

func _on_Hurtbox_area_entered(_area):
	create_grass_effect()
	queue_free()
