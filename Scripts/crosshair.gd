extends Control

@onready var crosshair_text = $CrosshairText
var crosshair_text_timer = 0.0
var crosshair_text_countdown = 0.2


func _process(delta):
	crosshair_text_timer -= delta
	if crosshair_text_timer <= 0:
		clear_crosshair_text()

func display_crosshair_text(text: String):
	crosshair_text.text = text
	crosshair_text_timer = crosshair_text_countdown
	
func clear_crosshair_text():
	crosshair_text.text = ""
