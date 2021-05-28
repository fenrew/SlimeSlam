extends Node2D

export (int) var speed = 400
export (int) var return_speed = 1000
export (int) var damage = 10

signal returned_home()

onready var current_speed = speed

var direction = Vector2.ZERO
var original_parent = null
var original_position = Vector2.ZERO
var target_position = Vector2.ZERO
var dmg_multiplier: int = 1
var travel_distance = 0
var returning_back = false

func _ready():
	set_physics_process(false)

func _physics_process(delta):
	position += direction * current_speed * delta
	if returning_back:
		set_direction(position, original_parent.position)
	elif (position - original_position).length() > travel_distance:
		set_physics_process(false)
		$Moving.hide()
		$Standing.show()
		$Standing/StandingCollision.disabled = false


func launch(start_pos, multiplier = 1):
	set_physics_process(true)
	$Moving.show()
	current_speed = speed
	original_position = start_pos
	dmg_multiplier = multiplier
	position = start_pos
	target_position = get_global_mouse_position()
	travel_distance = (target_position - start_pos).length()
	direction = (target_position - start_pos).normalized()
	var new_rotation = (target_position - position).angle()
	if abs(new_rotation) > 1.5:
		$Moving/Moving.set_flip_v(true)
		$Standing/StandingAnimation.set_flip_v(true)
	else:
		$Moving/Moving.set_flip_v(false)
		$Standing/StandingAnimation.set_flip_v(false)		
	rotation = new_rotation
	original_parent = get_parent()
	
	var scene = get_tree().current_scene
	original_parent.remove_child(self)
	scene.add_child(self)

func return_home(player_position):
	returning_back = true
	set_physics_process(true)
	$Standing.hide()
	$Moving.hide()
	$Returning.show()
	$Standing/StandingCollision.disabled = true
	$Returning/ReturningCollision.disabled = false
	current_speed = return_speed
	set_direction(position, player_position)

func set_direction(start_position, target_position):
	direction = (target_position - start_position).normalized()

func _on_Standing_body_entered(body):
	if body.is_in_group("player") and not body == original_parent:
		print("damage: ", damage * 2)

func _on_Returning_body_entered(body):
	print("COLLISION", original_parent == body)
	if original_parent == body and returning_back:
		returning_back = false
		set_physics_process(false)
		$Returning.hide()
		$Returning/ReturningCollision.disabled = true
		emit_signal("returned_home")
		var scene = get_tree().current_scene
		original_parent.add_child(self)
		scene.remove_child(self)


