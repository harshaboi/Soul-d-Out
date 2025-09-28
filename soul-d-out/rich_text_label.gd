extends RichTextLabel

# List of texts to cycle through
var texts = ["You are unlike the others", "Fetch me one soul each day, or else you will not be lucky enough to resurface again."]

var current_index = 0

func _ready():
	$LAUGJ.play()
	text = texts[current_index]  # Set initial text

func _input(event):
	if event.is_action_pressed("ui_accept"): # By default, "ui_accept" is the space bar / enter
		_change_text()
func _change_scene():
	get_tree().change_scene_to_file("res://main.tscn")
func _change_text():
	current_index += 1
	if current_index >= texts.size():
		_change_scene()
	else:
		text = texts[current_index]
