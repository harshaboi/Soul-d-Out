extends CharacterBody2D

# ---------------- Stats ----------------
const SPEED: float = 0  # Set >0 if you want walking enemies
const MAX_HP: int = 3
const ATTACK_DAMAGE: int = 1
const COINS_ON_DEATH: int = 5
const SOULS_ON_DEATH: int = 1

var hp: int = MAX_HP

# ---------------- Node References ----------------
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea

# ---------------- Signals ----------------
signal died

# ---------------- Ready ----------------
func _ready():
	# Disable attack area initially
	if attack_area:
		attack_area.monitoring = false
		attack_area.body_entered.connect(_on_attack_area_body_entered)

# ---------------- Physics ----------------
func _physics_process(_delta: float) -> void:
	# Optional movement logic here
	move_and_slide()

# ---------------- Attack ----------------
func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(ATTACK_DAMAGE)

# ---------------- Take Damage ----------------
func take_damage(amount: int):
	hp -= amount
	if hp <= 0:
		die()
	else:
		# Enable attack area only when attacked
		if attack_area:
			attack_area.monitoring = true
			# Optional: disable after 1 second
			await get_tree().create_timer(1.0).timeout
			attack_area.monitoring = false

# ---------------- Die ----------------
func die():
	var rng = RandomNumberGenerator.new()
	# Drop rewards
	var player = get_tree().get_root().find_node("Player", true, false)
	if player:
		if player.has_method("add_coin"):
			if player.hasGreed:
				player.add_coin(COINS_ON_DEATH + 3)
			else:
				player.add_coins(COINS_ON_DEATH)
		if player.has_method("add_soul"):
			if player.hasGluttony:
				player.add_soul(SOULS_ON_DEATH)
			else:
				player.add_soul(SOULS_ON_DEATH + (SOULS_ON_DEATH * rng.randi_range(0, 1)))
	
	emit_signal("died")
	queue_free()
