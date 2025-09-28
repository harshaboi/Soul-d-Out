extends CharacterBody2D

# ---------------- Movement ----------------
var SPEED: float = 300.0 # not constant because if has wrath, can be faster
const JUMP_VELOCITY: float = -400.0
const MAX_JUMPS: int = 2
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
		jump_count = 0
	# Jump
	if Input.is_action_just_pressed("jump") and jump_count < MAX_JUMPS:
		velocity.y = JUMP_VELOCITY
		jump_count += 1
	
	# Movement
	var direction = Input.get_axis("left", "right")
	if direction != 0:
		velocity.x = direction * SPEED
		sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()
	
	# Respawn if falling
	if global_position.y >= 400:
		respawn()

# ---------------- Process ----------------
func _process(_delta):
	# Movement animation
	if Input.is_action_pressed("left") or Input.is_action_pressed("right"):
		sprite.play("walk")
	else:
		sprite.play("idle")
	# Attack input
	if Input.is_action_just_pressed("attack"):
		attack()
	if hasWrath:
		SPEED = 400;
		attack_damage = 2;

# ---------------- Attack ----------------
func attack():
	if attack_area:
		sprite.play("attack")  # full attack animation
		attack_area.monitoring = true
		await get_tree().create_timer(0.2).timeout
		attack_area.monitoring = false

# ---------------- Attack Collision ----------------
func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy") and body.has_method("take_damage"):
		body.take_damage(1)

# ---------------- Damage ----------------
func take_damage(amount: int):
	hp -= amount
	if hp < 0:
		hp = 0
	update_health_ui()
	if hp <= 0:
		sprite.play("death")
		respawn()
		sprite.play("death")

# ---------------- Respawn ----------------
func respawn():
	hp = max_hp
	global_position = checkpoint_position
	jump_count = 0
	update_health_ui()

# ---------------- Rewards ----------------
func add_coin(amount: int = 1):
	coins += amount
	update_coin_ui()

func add_soul(amount: int = 1):
	souls += amount
	update_soul_ui()

# ---------------- UI ----------------
func update_health_ui():
	for i in range(1, max_hp + 1):
		var heart_node = hearts_container.get_node("Heart %d" % i)
		if heart_node:
			heart_node.visible = i <= hp

func update_coin_ui():
	if coin_label:
		coin_label.text = "Coins: %d" % coins

func update_soul_ui():
	if soul_label:
		soul_label.text = "Souls: %d" % souls
