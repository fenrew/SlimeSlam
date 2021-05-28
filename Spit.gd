extends Area2D

signal spell_hit

var speed = 600
var projectile_travel_distance = 800
var direction = Vector2.ZERO
var original_parent = null
var original_position = Vector2.ZERO
var dmg_multiplier = 1
var damage = 10

func _physics_process(delta):
	position += direction * speed * delta
	if (position - original_position).length() > projectile_travel_distance:
		queue_free()


func _on_Spit_body_entered(body):
	#if not body.is_a_parent_of(self):
	if not original_parent == body:
		print("DAMAGE", damage * dmg_multiplier)
		emit_signal("spell_hit")
		queue_free()

func launch(start_pos, multiplier):
	dmg_multiplier = multiplier
	position = start_pos
	original_position = start_pos
	var mouse_position = get_global_mouse_position()
	direction = (mouse_position - start_pos).normalized()
	#look_at(mouse_position)
	rotation = (mouse_position - position).angle()
	original_parent = get_parent()
	
	var scene = get_tree().current_scene
	original_parent.remove_child(self)
	scene.add_child(self)
