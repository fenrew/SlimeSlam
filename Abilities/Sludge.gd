extends Area2D

export (int) var speed = 450
export (int) var damage = 20
export (float) var slow_multiplier = -0.6

var projectile_travel_distance = 800
var direction = Vector2.ZERO
var original_parent = null
var original_position = Vector2.ZERO
var dmg_multiplier = 1
var exploded = false

func _ready():
	$Explosion.hide()

func _physics_process(delta):
	position += direction * speed * delta
	if (position - original_position).length() > projectile_travel_distance:
		explode()


func _on_Sludge_body_entered(body):
	#if not body.is_a_parent_of(self):
	if exploded and body.is_in_group("player"):
		print("SLOWED", body)
		body.add_speed_multiplier(slow_multiplier)
	elif not original_parent == body:
		print("DAMAGE", damage * dmg_multiplier)

func _on_Sludge_body_exited(body):
	if exploded and body.is_in_group("player"):
		print("NO LONGER SLOWED", body)
		body.remove_speed_multiplier(slow_multiplier)


func launch(start_pos, multiplier = 1):
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
	
func explode():
	set_physics_process(false)
	$ProjectileCollisionShape2D.disabled = true
	$ExplosionCollisionShape2D.disabled = false
	$Projectile.hide()
	$Explosion.frame = 0
	$Explosion.show()
	$Explosion.play()
	$ExplosionDuration.start()
	exploded = true


func _on_Explosion_animation_finished():
	$Explosion.stop()
	$Explosion.frame = 3


func _on_ExplosionDuration_timeout():
	queue_free()
