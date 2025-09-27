extends CharacterBody2D

# ---------------- Movement ----------------
const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const MAX_JUMPS = 2

# ---------------- Stats ----------------
var max_hp: int = 5
var hp: int = 5
var attack_damage: int = 1
var can_attack: bool = true

# ---------------- Respawn ----------------
var checkpoint_position: Vector2
var jump_count: int = 0

# ---------------- Node References ----------------
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var attack_active_timer: Timer = $AttackActiveTimer
@onready var attack_cooldown_timer: Timer = $AttackCooldownTimer

@onready var coin_label: CoinLabel = get_tree().root.get_node("Main/UI/CoinLabel") as CoinLabel
@onready var soul_meter: SoulMeter = get_tree().root.get_node("Main/UI/SoulLabel") as SoulMeter

# ---------------- Ready ----------------
func _ready():
	checkpoint_position = global_position
	add_to_group("player")
	attack_area.monitoring = false
	update_health_ui()

# ---------------- Physics ----------------
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		jump_count = 0

	# Jump (double jump)
	if Input.is_action_just_pressed("jump") and jump_count < MAX_JUMPS:
		velocity.y = JUMP_VELOCITY
		jump_count += 1

	# Movement
	var direction := Input.get_axis("left", "right")
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
	if Input.is_action_pressed("right") or Input.is_action_pressed("left"):
		sprite.play("walk")
	else:
		sprite.play("idle")

	if Input.is_action_just_pressed("attack") and can_attack:
		start_attack()

# ---------------- Attack ----------------
func start_attack():
	if not can_attack:
		return
	can_attack = false
	attack_area.monitoring = true
	attack_active_timer.start()    # active 0.2s
	attack_cooldown_timer.start()  # cooldown 0.5s

func _on_AttackActiveTimer_timeout():
	attack_area.monitoring = false

func _on_AttackCooldownTimer_timeout():
	can_attack = true

func _on_AttackArea_body_entered(body: Node2D):
	if body.is_in_group("enemy") and body.has_method("take_damage"):
		body.take_damage(attack_damage)

# ---------------- Damage & Respawn ----------------
func take_damage(amount: int):
	hp -= amount
	if hp < 0:
		hp = 0
	update_health_ui()
	if hp <= 0:
		respawn()

func respawn():
	hp = max_hp
	global_position = checkpoint_position
	jump_count = 0
	print("Respawned at checkpoint:", checkpoint_position)

# ---------------- Rewards ----------------
func add_coin(amount: int = 1):
	if coin_label != null:
		coin_label.add_coin(amount)

func add_soul(amount: int = 1):
	if soul_meter != null:
		soul_meter.add_soul(amount)

# ---------------- UI Updates ----------------
