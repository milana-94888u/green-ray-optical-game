extends Node2D

@onready var root_ray := $RayNode as RayNode
@onready var map := $TileMap


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	var angle = randf() * 2 * PI
	var initial_point = Vector2.ZERO / 2

	root_ray.setup(initial_point, angle)
	
	_generate_maze()

func _set_camera(rectangle: Rect2) -> void:
	rectangle = Rect2(rectangle.position - Vector2(100, 100), rectangle.size + Vector2(100, 100))
	$Camera2D.position = rectangle.position
	var zoom_x := get_viewport_rect().size.x / (rectangle.size.x + 200)
	var zoom_y := get_viewport_rect().size.y / (rectangle.size.y + 200)
	$Camera2D.zoom = Vector2(zoom_x, zoom_y)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta) -> void:
	_set_camera(root_ray.get_rectangle())


func _generate_maze() -> void:
	map.set_cell(0, Vector2i(4, 2), 1, Vector2i.ZERO)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		root_ray.split()
	elif event is InputEventMouseButton and event.is_pressed():
		var rectangle := root_ray.get_rectangle()
		rectangle = Rect2(rectangle.position - Vector2(100, 100), rectangle.size + Vector2(100, 100))
		var zoom_x := (rectangle.size.x + 200) / get_viewport_rect().size.x
		var zoom_y := (rectangle.size.y + 200) / get_viewport_rect().size.y
		var position_x: float = rectangle.position.x + event.position.x * zoom_x
		var position_y: float = rectangle.position.y + event.position.y * zoom_y

		var distance_and_ray = root_ray.find_closest_ray(Vector2(position_x, position_y))
		if distance_and_ray[0] > 10:
			return
		(distance_and_ray[1] as RayNode).destroy_by_user()
