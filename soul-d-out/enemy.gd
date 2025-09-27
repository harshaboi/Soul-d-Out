extends CharacterBody2D

# ---------------- Stats ----------------
var max_hp: int = 3
var hp: int = 3
var attack_damage: int = 1
var coin_drop: int = 5
var soul_drop: int = 1
var can_attack: bool = true

# ---------------- Node References ----------------
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var attack_timer: Timer = $AttackTimer

# ---------------- Ready ----------------
func _ready():
	add_to_group("enemy")
	if attack_area:
		attack_area.monitoring = false

# ---------------- Physics ----------------
func _physics_process(_delta: float) -> void:
	# Optional: simple AI or idle logic can go here
	pass

# ---------------- Attack ----------------
# Call this when the enemy wants to attack
func start_attack():
	if can_attack:
		attack_area.monitoring = true
		attack_timer.start()
		can_attack = false

func _on_AttackTimer_timeout():
	if attack_area:
		attack_area.monitoring = false
	can_attack = true

func _on_AttackArea_body_entered(body: Node2D):
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(attack_damage)

# ---------------- Damage & Death ----------------
func take_damage(amount: int):
	hp -= amount
	if hp <= 0:
		die()
	else:
		# Optionally attack back if hit
		start_attack()

func die():
	# Reward the player
	var player = get_tree().get_nodes_in_group("player")[0] if get_tree().get_nodes_in_group("player").size() > 0 else null
	if player != null:
		if player.has_method("add_coin"):
			player.add_coin(coin_drop)
		if player.has_method("add_soul"):
			player.add_soul(soul_drop)
	queue_free()
