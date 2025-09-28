extends Node2D

# ---------------- Exports ----------------
@export var PlayerScene: PackedScene
@export var Main: PackedScene
@export var GroundTileMap: TileMap
@export var MaxEnemies: int = 10
@export var SpawnInterval: float = 3.0
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
	if player.velocity.x == player.velocity.x  :
		var thingyfloor = get_node("GroundTileMap")
		var floorthingy = thingyfloor.duplicate()
		if Input.is_action_pressed("right"):
			floorthingy.position.x = player.global_position.x-100
			await get_tree().create_timer(0.1).timeout
		if Input.is_action_pressed("left"):
			floorthingy.position.x = player.global_position.x	
			await get_tree().create_timer(0.1).timeout
		self.add_child(floorthingy)

# ---------------- Terrain Generation ----------------
# ---------------- Enemy Spawning ----------------
func _on_spawn_timer_timeout():
	if enemies_spawned.size() >= MaxEnemies:
		return

	var positions = get_valid_ground_positions()
	if positions.size() == 0:
		return

	var random_pos = positions[randi() % positions.size()]
	var enemy = Main.instantiate()
	enemy.global_position = random_pos
	add_child(enemy)
	enemies_spawned.append(enemy)

	if enemy.has_signal("died"):
		enemy.died.connect(Callable(self, "_on_enemy_died"), [enemy])

func _on_enemy_died(enemy):
	if enemies_spawned.has(enemy):
		enemies_spawned.erase(enemy)

# ---------------- Helper Function ----------------
func get_valid_ground_positions() -> Array:
	var positions = []
	if not GroundTileMap:
		return positions

	var used_cells = GroundTileMap.get_used_cells(0)  # layer 0
	for cell in used_cells:
		var tile_id = GroundTileMap.get_cell(0, cell.x, cell.y)
		if tile_id == -1:
			continue
		var world_pos = GroundTileMap.map_to_world(cell)
		world_pos.y -= GroundTileMap.cell_size.y  # place enemy on top of tile
		positions.append(world_pos)
	return positions
	
