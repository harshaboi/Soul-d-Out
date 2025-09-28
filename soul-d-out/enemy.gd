extends CharacterBody2D

signal died

# ---------------- Stats ----------------
var hp: int = 3
var speed: float = 100.0
var attack_damage: int = 1
var gravity: float = 1200.0
var attack_cooldown: float = 1.0
var coins_on_death: int = 3
var souls_on_death: int = 1

# ---------------- State ----------------
var player: Node = null
var can_attack: bool = true
var aggro: bool = false   # Only attack after provoked

# ---------------- Node References ----------------
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea

# ---------------- Ready ----------------
func _ready():
	add_to_group("enemy")

	# Find player safely
	player = get_tree().get_root().find_child("Player", true, false)

	# Connect attack area
	if attack_area:
		attack_area.body_entered.connect(_on_attack_area_body_entered)

# ---------------- Physics ----------------
func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	# Move only if provoked
	if player and aggro:
		var direction = (player.global_position - global_position).normalized()
		velocity.x = direction.x * speed
	else:
		velocity.x = 0

	move_and_slide()

# ---------------- Damage ----------------
func take_damage(amount: int):
	hp -= amount
	aggro = true  # Enemy becomes aggressive when attacked
	if hp <= 0:
		die()

# ---------------- Attack ----------------
func _on_attack_area_body_entered(body: Node2D) -> void:
	if aggro and body.is_in_group("player") and can_attack:
		if body.has_method("take_damage"):
			body.take_damage(attack_damage)
		can_attack = false
		await get_tree().create_timer(attack_cooldown).timeout
		can_attack = true

# ---------------- Death ----------------
func die():
	# Drop rewards for player
	if player:
		if player.has_method("add_coin"):
			player.add_coin(coins_on_death)
		if player.has_method("add_soul"):
			player.add_soul(souls_on_death)

	emit_signal("died")
	queue_free()
