extends TextureButton

export var COOLDOWN = 2.0
export var BUFF_NAME = "buff_name"

onready var time_label = $Value

func _ready():
	hide()
	$Timer.wait_time = COOLDOWN
	$Sweep.texture_progress = texture_normal
	$Sweep.value = 0
	set_process(false)

func _process(delta):
	$Sweep.value = int(($Timer.time_left / COOLDOWN) * 100)

func _on_Timer_timeout():
	hide()
	if time_label:
		time_label.hide()
	$Sweep.value = 0
	disabled = false
	set_process(false)


func _on_Player_buff_activated(buff: String, label_value = null):
	if buff == BUFF_NAME:
		show()
		disabled = true
		set_process(true)
		$Timer.start()
		if label_value:
			time_label.text = label_value
			time_label.show()


func _on_Player_buff_deactivated(buff: String):
	if buff == BUFF_NAME:
		_on_Timer_timeout()
