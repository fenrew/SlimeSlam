extends CollisionShape2D


func check_position_for_collision(target_position: Vector2):
	return get_world_2d().direct_space_state.intersect_point( target_position )
