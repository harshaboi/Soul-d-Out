extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Y limit before respawn
const DEATH_Y = 400.0

var respawn_position: Vector2

@onready var _animated_sprite = $AnimatedSprite2D

func _ready():
	respawn_position = global_position

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("left", "right")
	
	if direction:
		if direction < 0:
			_animated_sprite.flip_h = true
		elif direction > 0:
			_animated_sprite.flip_h = false

		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	# 🔽 Auto-respawn check
	if global_position.y >= DEATH_Y:
		respawn()

func _process(_delta):
	if Input.is_action_pressed("right") or Input.is_action_pressed("left"):
		_animated_sprite.play("walk")
	else:
		_animated_sprite.stop()

func set_checkpoint(pos: Vector2):
	respawn_position = pos
	print("Checkpoint updated:", respawn_position)

func respawn():
	global_position = respawn_position
	velocity = Vector2.ZERO
	print("Respawned at:", respawn_position)
