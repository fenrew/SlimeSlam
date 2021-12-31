extends Node2D

export (int) var ability_range = 300

var cast_count = 0
var player = null

func cast(original_owner):
	if cast_count == 0:
		cast_initial_portal(original_owner)
	elif cast_count == 1:
		cast_secondary_portal()
	else:
		cast_third_portal()


func cast_initial_portal(original_owner):
	player = original_owner
	cast_count += 1
	var target_pos = original_owner.get_global_mouse_position()
	if (target_pos - original_owner.position).length() > ability_range:
		target_pos = original_owner.position + (target_pos - original_owner.position).normalized() * ability_range
	target_pos = original_owner.get_closest_unoccupied_position(target_pos, 50, original_owner.position)
	if not target_pos:
		target_pos = original_owner.position
	position = target_pos


func cast_secondary_portal():
	cast_count += 1
	$Portal.animation = "PortalTwo"


func cast_third_portal():
	player.position = position
	player.target = position
	queue_free()
