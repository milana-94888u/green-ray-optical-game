extends Node2D

@onready var root_ray := $RayNode as RayNode


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	var angle = randf() * 2 * PI
	var initial_point = get_viewport().get_visible_rect().size / 2

	root_ray.setup(initial_point, angle)
	print(roundi(float(10) / (-2.0)))


func _set_camera(rectangle: Rect2) -> void:
	rectangle = Rect2(rectangle.position - Vector2(100, 100), rectangle.size + Vector2(100, 100))
	# print(rectangle.end)
	$Camera2D.position = rectangle.position
	var zoom_x := get_viewport_rect().size.x / (rectangle.size.x + 200)
	var zoom_y := get_viewport_rect().size.y / (rectangle.size.y + 200)
	# print(get_viewport_rect().size.length() / rectangle.size.length())
	$Camera2D.zoom = Vector2(zoom_x, zoom_y)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta) -> void:
	_set_camera(root_ray.get_rectangle())


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		root_ray.split()
	elif event is InputEventMouseButton:
		var distance_and_ray = root_ray.find_closest_ray(event.position)
		if distance_and_ray[0] > 10:
			return
		(distance_and_ray[1] as RayNode).destroy_by_user()
