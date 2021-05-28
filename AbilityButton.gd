extends TextureButton

onready var time_label = $Value

export var COOLDOWN = 2.0
export var ABILITY_NAME = "ability_name"

func _ready():
	$Timer.wait_time = COOLDOWN
	time_label.hide()
	$Sweep.texture_progress = texture_normal
	$Sweep.value = 0
	set_process(false)

func _process(delta):
	time_label.text = "%3.1f" % $Timer.time_left
	$Sweep.value = int(($Timer.time_left / COOLDOWN) * 100)

func _on_Timer_timeout():
	print("ability ready")
	$Sweep.value = 0
	disabled = false
	time_label.hide()
	set_process(false)


func _on_Player_cast_ability(ability):
	if(ability == ABILITY_NAME):
		disabled = true
		set_process(true)
		$Timer.start()
		time_label.show()
