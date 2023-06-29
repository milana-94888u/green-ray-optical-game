extends Node2D

const VIEW_RECTANGLE_OFFSET := Vector2(100, 100)
const ZOOM_RECTANGLE_EXPANDING_OFFSET := Vector2(200, 200)
const MIN_DISTANCE_TO_DESTROY_RAY := 10.0

const TILE_CHUNK_WIDTH := 8
const TILE_CHUNK_HEIGHT := 8

@onready var root_ray := $RayNode as RayNode
@onready var map := $TileMap


func _ready() -> void:
	randomize()
	var angle := randf_range(0.0, TAU)
	var initial_point := Vector2.ZERO

	root_ray.setup(initial_point, angle)
	
	_generate_walls()


func _set_camera(rectangle: Rect2) -> void:
	rectangle = Rect2(
		rectangle.position - VIEW_RECTANGLE_OFFSET,
		rectangle.size + VIEW_RECTANGLE_OFFSET,
	)
	$Camera2D.position = rectangle.position
	var zoom_x := get_viewport_rect().size.x / (rectangle.size.x + ZOOM_RECTANGLE_EXPANDING_OFFSET.x)
	var zoom_y := get_viewport_rect().size.y / (rectangle.size.y + ZOOM_RECTANGLE_EXPANDING_OFFSET.y)
	$Camera2D.zoom = Vector2(zoom_x, zoom_y)


func _process(_delta) -> void:
	_set_camera(root_ray.get_rectangle())


func _fill_chunk(chunk_top_left: Vector2i) -> void:
	for x in range(TILE_CHUNK_WIDTH):
		for y in range(TILE_CHUNK_HEIGHT):
			map.set_cell(0, chunk_top_left + Vector2i(x, y), 1, Vector2i.ZERO)

func _draw_wall(
	wall_start: Vector2i,
	wall_end: Vector2i,
	wall_x_direction: Vector2i,
	wall_y_direction: Vector2i
) -> void:
	var current_wall_tile := wall_start
	while current_wall_tile != wall_end:
		map.set_cell(0, current_wall_tile, 0, Vector2i.ZERO)
		if current_wall_tile.x == wall_end.x:
			current_wall_tile += wall_y_direction
		elif current_wall_tile.y == wall_end.y:
			current_wall_tile += wall_x_direction
		else:
			current_wall_tile += wall_x_direction if randi_range(0, 1) else wall_y_direction


func _generate_chunk(x: int, y: int) -> void:
	var chunk_top_left := Vector2i(x * TILE_CHUNK_WIDTH, y * TILE_CHUNK_HEIGHT)
	_fill_chunk(chunk_top_left)
	
	var wall_start := chunk_top_left + Vector2i(
		randi_range(0, TILE_CHUNK_WIDTH - 1), randi_range(0, TILE_CHUNK_HEIGHT - 1)
	)
	var wall_end := chunk_top_left + Vector2i(
		randi_range(0, TILE_CHUNK_WIDTH - 1), randi_range(0, TILE_CHUNK_HEIGHT - 1)
	)
	var wall_x_direction := Vector2i.LEFT if wall_end.x < wall_start.x else Vector2i.RIGHT
	var wall_y_direction := Vector2i.UP if wall_end.y < wall_start.y else Vector2i.DOWN
	_draw_wall(wall_start, wall_end, wall_x_direction, wall_y_direction)


func _generate_walls() -> void:
	var width := 10
	var height := 10
	
	for x in range(-width, width):
		for y in range(-height, height):
			_generate_chunk(x, y)


func _process_click(click_position: Vector2) -> void:
	var rectangle := root_ray.get_rectangle()
	rectangle = Rect2(
		rectangle.position - VIEW_RECTANGLE_OFFSET,
		rectangle.size + VIEW_RECTANGLE_OFFSET,
	)
	var zoom_x := (rectangle.size.x + ZOOM_RECTANGLE_EXPANDING_OFFSET.x) / get_viewport_rect().size.x
	var zoom_y := (rectangle.size.y + ZOOM_RECTANGLE_EXPANDING_OFFSET.y) / get_viewport_rect().size.y
	var position_x := rectangle.position.x + click_position.x * zoom_x
	var position_y := rectangle.position.y + click_position.y * zoom_y

	var distance_and_ray := root_ray.find_closest_ray(Vector2(position_x, position_y))
	if distance_and_ray.distance > MIN_DISTANCE_TO_DESTROY_RAY:
		return
	distance_and_ray.ray.destroy_by_user()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		root_ray.split()
	elif event is InputEventMouseButton:
		if event.is_pressed():
			_process_click(event.position)
