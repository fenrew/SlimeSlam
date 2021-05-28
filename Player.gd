extends KinematicBody2D

export (int) var speed = 300
export (int) var MAX_HEALTH = 500

export (PackedScene) var Spit
export (PackedScene) var Warp
export (PackedScene) var Sludge
export (PackedScene) var Zimp

signal cast_ability(ability)
signal buff_activated(buff)
signal buff_deactivated(buff)

onready var zimp_inst = Zimp.instance()

var WARP_RANGE = 300

var current_health = MAX_HEALTH
# Contains Name of slow and multiplier
var speed_multipliers = []
var speed_multiplier = 1
var target = Vector2()
var velocity = Vector2()
var spit_stack = 1
var before_warp_position = Vector2.ZERO
var sludge_inst = null
var is_zimp_home = true


func _input(event):
	if event.is_action_pressed("click"):
		target = get_global_mouse_position()
		
	var just_pressed = event.is_pressed() and not event.is_echo()
	if Input.is_action_just_pressed("spell_slot_one"):
		shoot_spit()
	if Input.is_action_just_pressed("spell_slot_two"):
		warp()
	if Input.is_action_just_pressed("spell_slot_three"):
		shoot_sludge()
	if Input.is_action_just_pressed("spell_slot_four") and $ZimpCooldown.is_stopped():
		if is_zimp_home:
			is_zimp_home = false
			shoot_zimp()
		else:
			zimp_inst.return_home(position)


func _physics_process(_delta):
	velocity = (target - position).normalized() * speed * speed_multiplier
	# rotation = velocity.angle()
	if (target - position).length() > 5:
		velocity = move_and_slide(velocity)
		$Ooze.animation = "walk"
		$Ooze/Hat.animation = "walk"
	else:
		$Ooze.animation = "standing"
		$Ooze/Hat.animation = "standing"


func _ready():
	target = position
	$Ooze.play("standing")
	$Ooze/Hat.play("standing")
	zimp_inst.connect("returned_home", self, "_on_Zimp_returned_home")	

func deal_damage_or_heal(value):
	current_health += int(value)
	if current_health <= 0:
		print("DIED, Emit death?")
	elif current_health > MAX_HEALTH:
		current_health = MAX_HEALTH

func add_speed_multiplier(multiplier):
	speed_multipliers.append(multiplier)
	update_speed_multiplier()

func remove_speed_multiplier(multiplier):
	speed_multipliers.erase(multiplier)
	update_speed_multiplier()	

func update_speed_multiplier():
	var new_multiplier = 1
	for multiplier in speed_multipliers:
		print(multiplier)
		new_multiplier += multiplier
	if new_multiplier < 0:
		new_multiplier = 1
	speed_multiplier = new_multiplier


func get_closest_unoccupied_position(target_pos: Vector2, max_iterations: int):
	var iteration = 0
	var updated_vector_pos = target_pos
	
	while iteration < max_iterations:
		if $FullBodyCollision.check_position_for_collision(updated_vector_pos).size() > 0:
			var length_of_vector = (target_pos - position).length()
			updated_vector_pos = position + ((updated_vector_pos - position).normalized() * (length_of_vector-20 * iteration))
			
			iteration += 1
		else:
			iteration = max_iterations + 1
	
	if iteration > max_iterations:
		return updated_vector_pos
	else:
		return null


func shoot_spit():
	if $SpitCooldown.is_stopped():
		$SpitCooldown.start()
		emit_signal("cast_ability", "spit")
		var spit_inst = Spit.instance()
		add_child(spit_inst)
		spit_inst.connect("spell_hit", self, "_on_Spit_spell_hit")
		spit_inst.launch(position, spit_stack)

func shoot_sludge():
	if $SludgeCooldown.is_stopped():
		$SludgeCooldown.start()
		emit_signal("cast_ability", "sludge")
		sludge_inst = Sludge.instance()
		add_child(sludge_inst)
		sludge_inst.launch(position)
	elif is_instance_valid(sludge_inst):
		sludge_inst.explode()
		sludge_inst = null

func shoot_zimp():
	add_child(zimp_inst)
	$Ooze/Hat.hide()
	zimp_inst.launch(position)

func _on_Zimp_returned_home():
	$Ooze/Hat.show()
	is_zimp_home = true
	$ZimpCooldown.start()
	emit_signal("cast_ability", "zimp")	
	

func warp():
	if $WarpCooldown.is_stopped() or not $WarpCooldown/WarpBackTimer.is_stopped():
		var target_pos = get_closest_unoccupied_position(get_global_mouse_position(), 5)
		if target_pos == null: 
			return false
		
		set_physics_process(false)
		var new_pos = Vector2.ZERO
		var warp_inst = Warp.instance()
		get_parent().add_child(warp_inst)
		if $WarpCooldown.is_stopped():
			emit_signal("cast_ability", "warp")
			$WarpCooldown.start()
			emit_signal("buff_activated", "warp_back")
			$WarpCooldown/WarpBackTimer.start()
			before_warp_position = position
			new_pos = warp_inst.execute_warp(position, target_pos, null)
		else:
			emit_signal("buff_deactivated", "warp_back")
			$WarpCooldown/WarpBackTimer.stop()
			new_pos = warp_inst.execute_warp(position, before_warp_position, true)
		position = new_pos
		target = new_pos
		$FullBodyCollision.disabled = true
		$HalfBodyCollision.disabled = false
		$Ooze.frame = 0
		$Ooze/Hat.frame = 0
		$Ooze.animation = "appear"
		$Ooze/Hat.animation = "appear"

func _on_Spit_spell_hit():
	emit_signal("buff_activated", "spit_stack", str(spit_stack))
	if spit_stack < 5:
		spit_stack += 1
		$SpitCooldown/SpitDamageReset.start()
	elif spit_stack == 5:
		$SpitCooldown/SpitDamageReset.start()		
		print("5 Hits in a row!!")


func _on_SpitDamageReset_timeout():
	spit_stack = 1


func _on_Ooze_animation_finished():
	if $Ooze.animation == "appear":
		set_physics_process(true)
		$Ooze.animation = "standing"
		$Ooze/Hat.animation = "standing"
		$FullBodyCollision.disabled = false
		$HalfBodyCollision.disabled = true
