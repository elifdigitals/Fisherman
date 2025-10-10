extends Node
@export var mashroom_scene: PackedScene
@onready var camera_2d: Camera2D = $"../player/Camera2D"
@onready var camera: Camera2D = get_viewport().get_camera_2d()

var spawn_margin = 20


func _on_timer_timeout() -> void:

	if camera == null:
		return
		
	var camera_pos = camera.global_position

	var viewport_size_in_world = get_viewport().get_visible_rect().size / camera.zoom
	
	var view_rect_min_x = camera_pos.x - viewport_size_in_world.x / 2
	var view_rect_max_x = camera_pos.x + viewport_size_in_world.x / 2
	var view_rect_min_y = camera_pos.y - viewport_size_in_world.y / 2
	var view_rect_max_y = camera_pos.y + viewport_size_in_world.y / 2
	

	var spawn_cordinates = Vector2.ZERO
	var side = randi() % 4
	
	match side:
		0: # Сверху
			spawn_cordinates.x = randf_range(view_rect_min_x, view_rect_max_x)
			spawn_cordinates.y = view_rect_min_y - spawn_margin
		1: # Снизу
			spawn_cordinates.x = randf_range(view_rect_min_x, view_rect_max_x)
			spawn_cordinates.y = view_rect_max_y + spawn_margin
		2: # Слева
			spawn_cordinates.x = view_rect_min_x - spawn_margin
			spawn_cordinates.y = randf_range(view_rect_min_y, view_rect_max_y)
		3: # Справа
			spawn_cordinates.x = view_rect_max_x + spawn_margin
			spawn_cordinates.y = randf_range(view_rect_min_y, view_rect_max_y)
	
	if mashroom_scene == null:
		push_error("Ошибка: Сцена 'mashroom_scene' не прикреплена в Инспекторе!")
		return
		
	var enemy = mashroom_scene.instantiate() as Node2D
	get_parent().add_child(enemy)
	enemy.global_position = spawn_cordinates
