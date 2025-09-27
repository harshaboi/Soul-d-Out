extends Label
class_name SoulMeter  # <--- add this line

var souls: int = 0

func _ready():
	update_label()

func add_soul(amount: int = 1) -> void:
	souls += amount
	update_label()

func remove_soul(amount: int = 1) -> void:
	souls = max(souls - amount, 0)
	update_label()

func update_label() -> void:
	text = "Souls: %d" % souls
