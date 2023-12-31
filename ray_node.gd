extends Line2D
class_name RayNode

const packed_ray_scene := preload("res://ray_node.tscn")

var score := 0
var direction: Vector2

var initial_angle: float
var left_angle: float
var right_angle: float

var left_ray: RayNode = null
var right_ray: RayNode = null


func is_leaf() -> bool:
	return not (is_instance_valid(left_ray) or is_instance_valid(right_ray))


func _get_own_rectangle() -> Rect2:
	var top_left := Vector2(min(points[0].x, points[-1].x), min(points[0].y, points[-1].y))
	var bottom_right := Vector2(max(points[0].x, points[-1].x), max(points[0].y, points[-1].y))
	return Rect2(top_left, bottom_right - top_left)


func get_rectangle() -> Rect2:
	if is_leaf():
		return _get_own_rectangle()
	var rectangle := Rect2()
	if is_instance_valid(left_ray):
		var left_rect := left_ray.get_rectangle()
		if rectangle != Rect2():
			rectangle = rectangle.expand(left_rect.position).expand(left_rect.end)
		else:
			rectangle = left_rect
	if is_instance_valid(right_ray):
		var right_rect := right_ray.get_rectangle()
		if rectangle != Rect2():
			rectangle = rectangle.expand(right_rect.position).expand(right_rect.end)
		else:
			rectangle = right_rect
	return rectangle


func _calculate_distance_from_point(point: Vector2) -> float:
	var line := points[-1] - points[0]
	var line0 := points[0] - point
	var line1 := points[-1] - point

	# checking if at least one of angles between the ray and the line to the limit point is obtuse
	if line.dot(line1) < 0 or line.dot(line0) > 0:
		return min(line0.length(), line1.length())
	var triangle_area := absf(
		line.y * point.x - line.x * point.y + 
		points[-1].x * points[0].y - points[-1].y * points[0].x
		)
	return triangle_area / line.length()


func setup(start_point: Vector2, angle: float) -> void:
	direction = Vector2(cos(angle), sin(angle))
	add_point(start_point)
	add_point(start_point + direction)
	initial_angle = angle
	left_angle = angle
	right_angle = angle
	
	$CollisionArea.position = start_point


func find_closest_ray(point: Vector2) -> RayDistance:
	if is_leaf():
		return RayDistance.new(_calculate_distance_from_point(point), self)
	if is_instance_valid(left_ray) and is_instance_valid(right_ray):
		var left_distance_and_ray := left_ray.find_closest_ray(point)
		var right_distance_and_ray := right_ray.find_closest_ray(point)
		if left_distance_and_ray.distance < right_distance_and_ray.distance:
			return left_distance_and_ray
		return right_distance_and_ray
	if is_instance_valid(left_ray):
		return left_ray.find_closest_ray(point)
	return right_ray.find_closest_ray(point)


func split() -> void:
	if is_leaf():
		left_ray = packed_ray_scene.instantiate()
		left_ray.setup(points[-1], left_angle)
		add_child(left_ray)
		right_ray = packed_ray_scene.instantiate()
		right_ray.setup(points[-1], right_angle)
		add_child(right_ray)
	else:
		if is_instance_valid(left_ray):
			left_ray.split()
		if is_instance_valid(right_ray):
			right_ray.split()

func destroy_by_user() -> void:
	queue_free()


func _process(_delta: float) -> void:
	if is_leaf():
		score += 1
		points[-1] += direction
		var collision: KinematicCollision2D = $CollisionArea.move_and_collide(direction)
		if collision != null:
			queue_free()
	left_angle += 0.01
	right_angle -= 0.01
