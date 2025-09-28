
extends Node2D

# ---------------- Exports ----------------
@export var PlayerScene: PackedScene
@export var EnemyScene: PackedScene
@export var GroundLayer: TileMapLayer
@export var MaxEnemies: int = 5
@export var SpawnInterval: float = 3.0
@export var GroundTileID: int = 0   # Tile ID to use for ground tiles
@export var InitialGroundLength: int = 20

# ---------------- Variables ----------------
var player: Node2D
var enemies_spawned: Array = []
var spawn_timer: Timer

# ---------------- Ready ----------------
func _ready():
	randomize()

	# Spawn or find player
	player = get_node_or_null("Player")
	if player == null and PlayerScene:
		player = PlayerScene.instantiate()
		add_child(player)
		player.global_position = Vector2(100, 200)

	# Generate initial ground
	extend_ground(0, InitialGroundLength)

	# Setup spawn timer
	spawn_timer = Timer.new()
	spawn_timer.wait_time = SpawnInterval
	spawn_timer.one_shot = false
	spawn_timer.autostart = true
	add_child(spawn_timer)
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)

# ---------------- Process ----------------
func _process(_delta):
	extend_ground_if_needed()

# ---------------- Terrain Generation ----------------
func extend_ground_if_needed():
	if not GroundLayer or not player:
		return

	var player_x = player.global_position.x
	var rightmost_x = get_rightmost_ground_x()

	if player_x + 400 > rightmost_x * GroundLayer.tile_set.tile_size.x:
		extend_ground(rightmost_x + 1, 10)

func get_rightmost_ground_x() -> int:
	var used_cells = GroundLayer.get_used_cells()
	if used_cells.is_empty():
		return 0

	var max_x = used_cells[0].x
	for cell in used_cells:
		if cell.x > max_x:
			max_x = cell.x
	return max_x

func extend_ground(start_x: int, count: int):
	if not GroundLayer:
		return

	for i in range(count):
		var cell_pos = Vector2i(start_x + i, 0)
		GroundLayer.set_cell(cell_pos, GroundTileID)

# ---------------- Enemy Spawning ----------------
func _on_spawn_timer_timeout():
	if enemies_spawned.size() >= MaxEnemies or not EnemyScene:
		return

	var positions = get_valid_ground_positions()
	if positions.is_empty():
		return

	var random_pos = positions[randi() % positions.size()]
	var enemy = EnemyScene.instantiate()
	enemy.global_position = random_pos
	add_child(enemy)
	enemies_spawned.append(enemy)

	if enemy.has_signal("died"):
		enemy.died.connect(func(): _on_enemy_died(enemy))

func _on_enemy_died(enemy):
	enemies_spawned.erase(enemy)

# ---------------- Helper Function ----------------
func get_valid_ground_positions() -> Array:
	var positions: Array = []
	if not GroundLayer:
		return positions

	for cell in GroundLayer.get_used_cells():
		var tile_id = GroundLayer.get_cell_source_id(cell)
		if tile_id == -1:
			continue

		var above_cell = Vector2i(cell.x, cell.y - 1)
		var above_id = GroundLayer.get_cell_source_id(above_cell)

		if above_id == -1:
			var world_pos = GroundLayer.map_to_local(cell)
			world_pos.y -= GroundLayer.tile_set.tile_size.y
			positions.append(world_pos)

	return positions
