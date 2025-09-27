extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Stores the current respawn checkpoint
var respawn_position: Vector2

@onready var _animated_sprite = $AnimatedSprite2D
@onready var _sprite = $Sprite2D

func _ready():
	# Set initial respawn position to where the player starts
	respawn_position = global_position

func _physics_process(delta: float) -> void:
	# Add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Handle movement input
	var direction := Input.get_axis("left", "right")
	
	if direction:
		# Flip sprite based on movement direction
		if direction < 0:
			_animated_sprite.flip_h = true
		elif direction > 0:
			_animated_sprite.flip_h = false

		velocity.x = direction * SPEED
		print("Direction:", direction, " Velocity X:", velocity.x)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Actually move the player in the physics step
	move_and_slide()

func _process(_delta):
	# Handle animation (visual only)
	if Input.is_action_pressed("right") or Input.is_action_pressed("left"):
		_animated_sprite.play("walk")
	else:
		_animated_sprite.stop()

# Called by checkpoint Area2D
func set_checkpoint(pos: Vector2):
	respawn_position = pos
	print("Checkpoint updated:", respawn_position)

# Respawn the player at last checkpoint
func respawn():
	global_position = respawn_position
	velocity = Vector2.ZERO
