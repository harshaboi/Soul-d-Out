extends Node2D

# ---------------- Exports ----------------
@export var PlayerScene: PackedScene
@export var EnemyScene: PackedScene
@export var GroundTileMap: TileMap
@export var MaxEnemies: int = 2
@export var SpawnInterval: float = 5.0
@export var GroundTileID: int = 0  # Tile ID for your ground

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
	if not player:
		return
	if player.velocity.x !=0  :
		var thingyfloor = get_node("GroundTileMap")
		var floorthingy = thingyfloor.duplicate()
		if Input.is_action_just_pressed("left"):
			floorthingy.position.x = player.global_position.x-100
		if Input.is_action_just_pressed("right"):
			floorthingy.position.x = player.global_position.x	
			await get_tree().create_timer(0.1).timeout
		self.add_child(floorthingy)

	# Duplicate ground tiles based on player movement
	var thingyfloor = get_node("GroundTileMap")
	var floorthingy = thingyfloor.duplicate()
	if Input.is_action_pressed("right"):
		floorthingy.position.x = player.global_position.x + 100
		await get_tree().create_timer(0.1).timeout
	elif Input.is_action_pressed("left"):
		floorthingy.position.x = player.global_position.x - 100
		await get_tree().create_timer(0.1).timeout
	self.add_child(floorthingy)

# ---------------- Enemy Spawning ----------------
func _on_spawn_timer_timeout():
	if enemies_spawned.size() >= MaxEnemies:
		return

	if not player:
		return

	# Random x within ±100 pixels of the player
	var spawn_x = player.global_position.x + randf_range(-100, 100)
	var spawn_y = player.global_position.y  # same y as player

	var enemy = EnemyScene.instantiate()
	enemy.global_position = Vector2(spawn_x, spawn_y)
	add_child(enemy)
	enemies_spawned.append(enemy)

	# Connect death signal
	if enemy.has_signal("died"):
		enemy.died.connect(Callable(self, "_on_enemy_died").bind(enemy))


func _on_enemy_died(enemy):
	if enemies_spawned.has(enemy):
		enemies_spawned.erase(enemy)
