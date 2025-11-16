extends Node

@export var attack_ability: PackedScene
@export var projectile_texture: Texture2D

var attack_range = 100
var sword_damage = 5
var projectile_damage = 3
var can_attack = true
var can_shoot = true
var attack_cooldown = 0.3
var shoot_cooldown = 0.5
var shoot_deadzone = 0.3

func _ready():
	Global.ability_upgrade_added.connect(on_upgrade_added)

func _input(event):
	if event.is_action_pressed("right_click") and can_attack:
		perform_attack()
	
	if event.is_action_pressed("shoot") and can_shoot:
		perform_shoot()

func perform_attack():
	if attack_ability == null:
		return
		
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
		
	var player_pos = player.global_position
		
	var enemies = get_tree().get_nodes_in_group("enemy")
	
	enemies = enemies.filter(func(enemy:Node2D):
		return enemy.global_position.distance_squared_to(player_pos) < pow(attack_range, 2)
	)
	
	if enemies.size() == 0:
		return
		
	enemies.sort_custom(func(a:Node2D, b:Node2D):
		var a_distance = a.global_position.distance_squared_to(player_pos)
		var b_distance = b.global_position.distance_squared_to(player_pos)
		return a_distance < b_distance
	)
	
	var enemy_pos = enemies[0].global_position
	
	var attack_instance = attack_ability.instantiate() as AttackAbility
	var front_layer = get_tree().get_first_node_in_group("front_layer")
	front_layer.add_child(attack_instance)
	attack_instance.hit_box_component.damage = sword_damage
	
	attack_instance.global_position = (enemy_pos + player_pos) / 2
	attack_instance.look_at(enemy_pos)
	
	start_attack_cooldown()

func perform_shoot():
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	
	var mouse_pos = get_viewport().get_mouse_position()
	var camera = get_viewport().get_camera_2d()
	if camera:
		mouse_pos = camera.global_position + mouse_pos - get_viewport().get_visible_rect().size / 2
	
	var player_pos = player.global_position
	
	var projectile = Area2D.new()
	var sprite = Sprite2D.new()
	var collision = CollisionShape2D.new()
	
	if projectile_texture:
		sprite.texture = projectile_texture
	else:
		var image = Image.create(8, 8, false, Image.FORMAT_RGBA8)
		image.fill(Color.RED)
		var texture = ImageTexture.create_from_image(image)
		sprite.texture = texture
	
	var shape = RectangleShape2D.new()
	shape.size = Vector2(6, 6)
	collision.shape = shape
	
	projectile.add_child(sprite)
	projectile.add_child(collision)
	
	var front_layer = get_tree().get_first_node_in_group("front_layer")
	front_layer.add_child(projectile)
	
	projectile.global_position = player_pos
	var direction = (mouse_pos - player_pos).normalized()
	
	setup_projectile(projectile, direction)
	
	start_shoot_cooldown()

func setup_projectile(projectile: Area2D, direction: Vector2):
	projectile.rotation = direction.angle()
	
	var hit_box = Area2D.new()
	var hit_box_collision = CollisionShape2D.new()
	var hit_box_shape = RectangleShape2D.new()
	hit_box_shape.size = Vector2(8, 8)
	hit_box_collision.shape = hit_box_shape
	hit_box.add_child(hit_box_collision)
	projectile.add_child(hit_box)
	
	hit_box.body_entered.connect(func(body):
		if body.has_method("take_damage"):
			body.take_damage(projectile_damage)
		projectile.queue_free()
	)
	
	hit_box.area_entered.connect(func(area):
		if area.get_parent().has_method("take_damage"):
			area.get_parent().take_damage(projectile_damage)
		projectile.queue_free()
	)
	
	var tween = create_tween()
	var speed = 400.0
	var max_distance = 500.0
	var target_position = projectile.global_position + direction * max_distance
	
	tween.tween_property(projectile, "global_position", target_position, max_distance / speed)
	tween.tween_callback(projectile.queue_free)

func start_attack_cooldown():
	can_attack = false
	var cooldown_timer = get_tree().create_timer(attack_cooldown)
	cooldown_timer.timeout.connect(_on_attack_cooldown_finished)

func _on_attack_cooldown_finished():
	can_attack = true

func start_shoot_cooldown():
	can_shoot = false
	var cooldown_timer = get_tree().create_timer(shoot_cooldown - shoot_deadzone)
	cooldown_timer.timeout.connect(_on_shoot_cooldown_finished)

func _on_shoot_cooldown_finished():
	can_shoot = true

func on_upgrade_added(upgrade:AbilityUpgrade, current_upgrades:Dictionary):
	if upgrade.id == "sword_rate":
		var upgrade_percent = current_upgrades["sword_rate"]["quantity"] * .1
		attack_cooldown = max(0.1, 0.3 * (1 - upgrade_percent))
	elif upgrade.id == "shoot_rate":
		var upgrade_percent = current_upgrades["shoot_rate"]["quantity"] * .1
		shoot_cooldown = max(0.1, 0.5 * (1 - upgrade_percent))
		shoot_deadzone = shoot_cooldown * 0.6
	elif upgrade.id == "projectile_damage":
		projectile_damage += 2
