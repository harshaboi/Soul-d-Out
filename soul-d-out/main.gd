extends Node2D

# ---------------- Exports ----------------
@export var PlayerScene: PackedScene
@export var EnemyScene: PackedScene
@export var GroundTileMap: TileMap
@export var MaxEnemies: int = 5
@export var SpawnInterval: float = 3.0
@export var GroundTileID: int = 0  # Tile ID for your ground

# ---------------- Variables ----------------
var player: Node
var enemies_spawned: Array = []
var spawn_timer: Timer

# ---------------- Ready ----------------
func _ready():
	randomize()

	# Instantiate player
	player = PlayerScene.instantiate()
	add_child(player)
	player.global_position = Vector2(100, 200)

	# Timer for enemy spawning
	spawn_timer = Timer.new()
	spawn_timer.wait_time = SpawnInterval
	spawn_timer.one_shot = false
	spawn_timer.autostart = true
	add_child(spawn_timer)
	spawn_timer.timeout.connect(Callable(self, "_on_spawn_timer_timeout"))

# ---------------- Process ----------------
func _process(_delta):
	extend_ground_if_needed()

# ---------------- Terrain Generation ----------------
func extend_ground_if_needed():
	var player_x = player.global_position.x
	var rightmost_x = get_rightmost_ground_x()
	
	# Extend ground ahead of player
	if player_x + 400 > rightmost_x * GroundTileMap.cell_size.x:
		extend_ground(rightmost_x + 1, 10)  # Add 10 tiles ahead

func get_rightmost_ground_x() -> int:
	var used_cells = GroundTileMap.get_used_cells(2)
	if used_cells.empty():
		return 0
	var max_x = used_cells[0].x
	for cell in used_cells:
		if cell.x > max_x:
			max_x = cell.x
	return max_x

func extend_ground(start_x: int, count: int):
	for i in range(count):
		var cell_pos = Vector2i(start_x + i, 0)
		GroundTileMap.set_cellv(cell_pos, GroundTileID)

# ---------------- Enemy Spawning ----------------
func _on_spawn_timer_timeout():
	if enemies_spawned.size() >= MaxEnemies:
		return

	var positions = get_valid_ground_positions()
	if positions.empty():
		return

	var random_pos = positions[randi() % positions.size()]
	var enemy = EnemyScene.instantiate()
	enemy.global_position = random_pos
	add_child(enemy)
	enemies_spawned.append(enemy)

	# Connect enemy death signal if exists
	if enemy.has_signal("died"):
		enemy.died.connect(Callable(self, "_on_enemy_died"), [enemy])

func _on_enemy_died(enemy):
	enemies_spawned.erase(enemy)

# ---------------- Helper Function ----------------
func get_valid_ground_positions() -> Array:
	var positions = []
	if not GroundTileMap:
		return positions

	var used_cells = GroundTileMap.get_used_cells(0)
	for cell in used_cells:
		var tile_id = GroundTileMap.get_cell(0, cell.x, cell.y)
		if tile_id == -1:
			continue
		var world_pos = GroundTileMap.map_to_world(cell)
		world_pos.y -= GroundTileMap.cell_size.y  # place enemy on top of tile
		positions.append(world_pos)
	return positions
