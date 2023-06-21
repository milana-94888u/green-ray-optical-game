extends Node2D

const packed_ray_scene := preload("res://ray_node.tscn")

var root_ray: RayNode


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	var angle = randf() * 2 * PI
	var initial_point = get_viewport().get_visible_rect().size / 2
	
	root_ray = packed_ray_scene.instantiate()
	root_ray.setup(initial_point, angle)
	add_child(root_ray)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta) -> void:
	pass


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		root_ray.split()
	elif event is InputEventMouseButton:
		var distance_and_ray = root_ray.find_closest_ray(event.position)
		if distance_and_ray[0] > 10:
			return
		(distance_and_ray[1] as RayNode).destroy_by_user()
