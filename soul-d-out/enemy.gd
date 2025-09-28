extends CharacterBody2D

# ---------------- Stats ----------------
const SPEED: float = 50.0
const MAX_HP: int = 3
const ATTACK_DAMAGE: int = 1
const COINS_ON_DEATH: int = 5
const SOULS_ON_DEATH: int = 1

var hp: int = MAX_HP
var player: Node2D = null

# ---------------- Node References ----------------
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea
var player: Node

# ---------------- Signals ----------------
signal died

# ---------------- Ready ----------------
func _ready():
	# Add to enemy group
	add_to_group("enemy")

	# Disable attack area initially
	if attack_area:
		attack_area.monitoring = true
		attack_area.body_entered.connect(_on_attack_area_body_entered)

	# Correct way to find the player in Godot 4
	player = get_tree().current_scene.get_node_or_null("Player")

# ---------------- Physics ----------------
func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	if player:
		# Move smoothly towards player
		var direction = (player.global_position - global_position).normalized()
		velocity.x = direction.x * SPEED
		move_and_slide()

# ---------------- Attack Collision ----------------
func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(ATTACK_DAMAGE)

# ---------------- Take Damage ----------------
func take_damage(amount: int):
	hp -= amount
	if hp <= 0:
		die()
	else:
		# Optional: briefly activate attack area when hit
		if attack_area:
			attack_area.monitoring = true
			await get_tree().create_timer(0.5).timeout


# ---------------- Die ----------------
func die():
var rng = RandomNumberGenerator.new()
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
