extends CharacterBody2D

# ---------------- Stats ----------------
const SPEED: float = 100.0          # Enemy movement speed
const MAX_HP: int = 3
const ATTACK_DAMAGE: int = 1
const COINS_ON_DEATH: int = 5
const SOULS_ON_DEATH: int = 1

var hp: int = MAX_HP
var player: Node2D = null

# ---------------- Node References ----------------
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea

# ---------------- Signals ----------------
signal died

# ---------------- Ready ----------------
func _ready():
	# Connect attack area
	if attack_area:
		attack_area.monitoring = true
		attack_area.body_entered.connect(_on_attack_area_body_entered)
	
	# Get the player node from the current scene
	player = get_tree().current_scene.get_node("Player") # Adjust path if nested
	
# ---------------- Physics ----------------
func _physics_process(_delta: float) -> void:
	if not player:
		return
	
	# Move toward player
	var direction = (player.global_position - global_position).normalized()
	velocity.x = direction.x * SPEED
	move_and_slide()
	
	# Flip sprite based on movement
	if direction.x != 0:
		sprite.flip_h = direction.x < 0

# ---------------- Attack Area Signal ----------------
func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(1)

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
			attack_area.monitoring = false

# ---------------- Die ----------------
func die():
<<<<<<< HEAD
	var rng = RandomNumberGenerator.new()
	# Drop rewards
	var player = get_tree().get_root().find_node("Player", true, false)
=======
>>>>>>> ec16e8b1800ac6289a98f989c7341c11515e2eaa
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
