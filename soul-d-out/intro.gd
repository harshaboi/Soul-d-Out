extends Node2D

@onready var timer: Timer = $Timer

func _ready():
	# When the timer runs out, switch to main game
	timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout():
	# Change scene to your main game scene
	get_tree().change_scene_to_file("res://main.tscn")
