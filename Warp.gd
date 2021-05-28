extends AnimatedSprite

export var WARP_RANGE = 300

func execute_warp(original_pos, target_pos, tp_back):
		frame = 0
		$Hat.frame = 0
		position = original_pos
		var new_pos = Vector2.ZERO
		if tp_back == true:
			new_pos = target_pos
		elif ((target_pos - original_pos).length() > WARP_RANGE):
			new_pos = original_pos + ((target_pos - original_pos).normalized() * WARP_RANGE)
		else:
			new_pos = target_pos
		
		return new_pos


func _on_Body_animation_finished():
	queue_free()
