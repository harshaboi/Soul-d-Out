
extends CharacterBody2D

# ---------------- Movement ----------------
const SPEED: float = 300.0
const JUMP_VELOCITY: float = -400.0
const MAX_JUMPS: int = 2  # Double jump allowed
var jump_count: int = 0

# ---------------- Stats ----------------
var max_hp: int = 5
var hp: int = 5
var coins: int = 0
var souls: int = 0
var attack_damage: int = 1
var hasGreed: bool = false
var hasWrath: bool = false
var hasGluttony: bool = false

# ---------------- Respawn ----------------
var checkpoint_position: Vector2

# ---------------- Node References ----------------
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var hearts_container: Node = $Camera2D/UI/HeartsContainer
@onready var coin_label: Label = $Camera2D/UI/CoinLabel
@onready var soul_label: Label = $Camera2D/UI/SoulLabel

# ---------------- Ready ----------------
func _ready():
	checkpoint_position = global_position
	add_to_group("player")

	if attack_area:
		attack_area.monitoring = false
		attack_area.body_entered.connect(_on_attack_area_body_entered)

	update_health_ui()
	update_coin_ui()
	update_soul_ui()

# ---------------- Physics ----------------
func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		jump_count = 0  # Reset jumps on floor

	# Jump
	if Input.is_action_just_pressed("jump") and jump_count < MAX_JUMPS:
		velocity.y = JUMP_VELOCITY
		jump_count += 1

	# Movement
	var direction = Input.get_axis("left", "right")
	if direction != 0:
		velocity.x = direction * SPEED
		sprite.flip_h = direction < 0
		if is_on_floor():
			sprite.play("walk")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if is_on_floor():
			sprite.play("idle")

	move_and_slide()

	# Respawn if falling
	if global_position.y >= 400:
		respawn()

# ---------------- Process ----------------
func _process(_delta):
	# Attack input
	if Input.is_action_just_pressed("attack"):
		attack()

# ---------------- Attack ----------------
func attack():
	if not attack_area:
		return

	sprite.play("attack")
	attack_area.monitoring = true

	# Disable hitbox after short delay
	await get_tree().create_timer(0.2).timeout
	attack_area.monitoring = false

# ---------------- Attack Area Signal ----------------
func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy") and body.has_method("take_damage"):
		body.take_damage(attack_damage)

# ---------------- Damage ----------------
func take_damage(amount: int):
	hp -= amount
	if hp < 0:
		hp = 0
	update_health_ui()
	if hp <= 0:
		respawn()

# ---------------- Respawn ----------------
func respawn():
	hp = max_hp
	global_position = checkpoint_position
	jump_count = 0
	update_health_ui()

# ---------------- Coins/Souls ----------------
func add_coin(amount: int = 1):
	coins += amount
	update_coin_ui()

func add_soul(amount: int = 1):
	souls += amount
	update_soul_ui()

# ---------------- UI Updates ----------------
func update_health_ui():
	for i in range(1, max_hp + 1):
		var heart_node = hearts_container.get_node("Heart %d" % i)
		heart_node.visible = (i == hp)

func update_coin_ui():
	if coin_label:
		coin_label.text = "Coins: %d" % coins

func update_soul_ui():
	if soul_label:
		soul_label.text = "Souls: %d" % souls
