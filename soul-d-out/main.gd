extends Node2D

# ---------------- Exports ----------------
@export var PlayerScene: PackedScene
@export var EnemyScene: PackedScene
@export var GroundTileMap: TileMap
@export var MaxEnemies: int = 5
@export var SpawnInterval: float = 3.0

# ---------------- Variables ----------------
var player: Node
var enemies_spawned: Array = []
var spawn_timer: Timer

# ---------------- Ready ----------------
func _ready():
	randomize()

	# Ensure only one player exists
	if not get_node_or_null("Player") and PlayerScene:
		player = PlayerScene.instantiate()
		player.name = "Player"
		add_child(player)
		player.global_position = Vector2(100, 200)
	else:
		player = get_node("Player")

	# Timer for enemy spawning
	spawn_timer = Timer.new()
	spawn_timer.wait_time = SpawnInterval
	spawn_timer.one_shot = false
	spawn_timer.autostart = true
	add_child(spawn_timer)
	spawn_timer.timeout.connect(Callable(self, "_on_spawn_timer_timeout"))

# ---------------- Process ----------------
func _process(_delta):
	# Duplicate ground depending on movement
	if player.velocity.x == player.velocity.x:
		var thingyfloor = get_node("GroundTileMap")
		var floorthingy = thingyfloor.duplicate()
		if Input.is_action_pressed("right"):
			floorthingy.position.x = player.global_position.x - 100
			await get_tree().create_timer(0.1).timeout
		if Input.is_action_pressed("left"):
			floorthingy.position.x = player.global_position.x
			await get_tree().create_timer(0.1).timeout
		self.add_child(floorthingy)

# ---------------- Enemy Spawning ----------------
func _on_spawn_timer_timeout():
	if enemies_spawned.size() >= MaxEnemies:
		return

	if not player:
		return

	# Spawn near player
	var offset_x = randf_range(-100, 100)
	var spawn_pos = Vector2(player.global_position.x + offset_x, player.global_position.y)

	var enemy = EnemyScene.instantiate()
	enemy.global_position = spawn_pos
	add_child(enemy)
	enemies_spawned.append(enemy)

	if enemy.has_signal("died"):
		enemy.died.connect(Callable(self, "_on_enemy_died").bind(enemy))

func _on_enemy_died(enemy):
	if enemies_spawned.has(enemy):
		enemies_spawned.erase(enemy)
