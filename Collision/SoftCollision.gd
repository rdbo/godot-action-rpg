extends Area2D

func get_push_vector():
	var push_vec = Vector2.ZERO
	var areas = get_overlapping_areas()
	if areas.size() > 0:
		push_vec = areas[0].global_position.direction_to(self.global_position)
		push_vec = push_vec.normalized()
	return push_vec
