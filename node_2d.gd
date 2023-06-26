extends Node2D

const VIEW_RECTANGLE_OFFSET := Vector2(100, 100)
const ZOOM_RECTANGLE_EXPANDING_OFFSET := Vector2(200, 200)
const MIN_DISTANCE_TO_DESTROY_RAY := 10.0

@onready var root_ray := $RayNode as RayNode
@onready var map := $TileMap


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	var angle := randf_range(0.0, TAU)
	var initial_point := Vector2.ZERO

	root_ray.setup(initial_point, angle)
	
	_generate_maze()

func _set_camera(rectangle: Rect2) -> void:
	rectangle = Rect2(
		rectangle.position - VIEW_RECTANGLE_OFFSET,
		rectangle.size + VIEW_RECTANGLE_OFFSET,
	)
	$Camera2D.position = rectangle.position
	var zoom_x := get_viewport_rect().size.x / (rectangle.size.x + ZOOM_RECTANGLE_EXPANDING_OFFSET.x)
	var zoom_y := get_viewport_rect().size.y / (rectangle.size.y + ZOOM_RECTANGLE_EXPANDING_OFFSET.y)
	$Camera2D.zoom = Vector2(zoom_x, zoom_y)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta) -> void:
	_set_camera(root_ray.get_rectangle())


func _generate_maze() -> void:
	map.set_cell(0, Vector2i(4, 2), 0, Vector2i.ZERO)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		root_ray.split()
	elif event is InputEventMouseButton and event.is_pressed():
		var rectangle := root_ray.get_rectangle()
		rectangle = Rect2(
			rectangle.position - VIEW_RECTANGLE_OFFSET,
			rectangle.size + VIEW_RECTANGLE_OFFSET,
		)
		var zoom_x := (rectangle.size.x + ZOOM_RECTANGLE_EXPANDING_OFFSET.x) / get_viewport_rect().size.x
		var zoom_y := (rectangle.size.y + ZOOM_RECTANGLE_EXPANDING_OFFSET.y) / get_viewport_rect().size.y
		var position_x: float = rectangle.position.x + event.position.x * zoom_x
		var position_y: float = rectangle.position.y + event.position.y * zoom_y

		var distance_and_ray := root_ray.find_closest_ray(Vector2(position_x, position_y))
		if distance_and_ray.distance > MIN_DISTANCE_TO_DESTROY_RAY:
			return
		distance_and_ray.ray.destroy_by_user()
