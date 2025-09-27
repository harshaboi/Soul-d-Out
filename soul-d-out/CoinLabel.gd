extends Label
class_name CoinLabel  # <--- add this line

var coins: int = 0

func _ready():
	update_label()

func add_coin(amount: int = 1) -> void:
	coins += amount
	update_label()

func remove_coin(amount: int = 1) -> void:
	coins = max(coins - amount, 0)
	update_label()

func update_label() -> void:
	text = "Coins: %d" % coins
