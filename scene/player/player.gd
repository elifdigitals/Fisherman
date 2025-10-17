extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var health = $Health

@export var SPEED: float = 60.0
@export var BulletScene: PackedScene
@export var AttackScene: PackedScene
@export var fire_rate: float = 4.0

var _shoot_cooldown: float = 0.0
var _is_attacking: bool = false
var knockback_velocity: Vector2 = Vector2.ZERO
var lastDirection: String = "S"

signal player_shooted
signal player_damaged(value)
signal player_died


func _ready():
	health.connect("died", Callable(self, "_on_died"))
	health.connect("damaged", Callable(self, "_on_damaged"))
	health.connect("health_changed", Callable(self, "_on_health_changed"))


func _process(delta):
	handle_movement(delta)
	handle_shooting(delta)
	handle_attack()
	handle_knockback(delta)


func handle_movement(delta):
	var move = Vector2(
		Input.get_action_strength("run_right") - Input.get_action_strength("run_left"),
		Input.get_action_strength("run_back") - Input.get_action_strength("run_forward")
	)

	var dir = move.normalized()
	velocity = dir * SPEED + knockback_velocity
	move_and_slide()

	# Анимации движения
	if move.x > 0:
		animated_sprite_2d.play("run_right")
		animated_sprite_2d.flip_h = false
		lastDirection = "D"
	elif move.x < 0:
		animated_sprite_2d.play("run_right")
		animated_sprite_2d.flip_h = true
		lastDirection = "A"
	elif move.y > 0:
		animated_sprite_2d.play("run")
		lastDirection = "S"
	elif move.y < 0:
		animated_sprite_2d.play("run_forward")
		lastDirection = "W"
	else:
		match lastDirection:
			"A":
				animated_sprite_2d.play("idle_right")
				animated_sprite_2d.flip_h = true
			"W":
				animated_sprite_2d.play("idle_forward")
			"S":
				animated_sprite_2d.play("idle")
			"D":
				animated_sprite_2d.play("idle_right")
				animated_sprite_2d.flip_h = false


func handle_shooting(delta):
	if _shoot_cooldown > 0:
		_shoot_cooldown = max(0, _shoot_cooldown - delta)

	if Input.is_action_pressed("shoot") and _shoot_cooldown <= 0:
		_shoot()
		_shoot_cooldown = 1.0 / fire_rate


func handle_attack():
	if Input.is_action_just_pressed("attack") and not _is_attacking:
		_start_melee()


func handle_knockback(delta):
	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, delta * 300)


func _shoot():
	if not BulletScene:
		return

	var bullet = BulletScene.instantiate()
	bullet.global_position = global_position
	var dir = (get_global_mouse_position() - global_position).normalized()
	bullet.direction = dir
	get_tree().current_scene.add_child(bullet)
	emit_signal("player_shooted")


func _start_melee():
	if not AttackScene:
		return

	_is_attacking = true
	var atk = AttackScene.instantiate()
	atk.global_position = global_position

	var dir = (get_global_mouse_position() - global_position).normalized()
	if "setup" in atk:
		atk.setup(self, dir)

	if atk.has_signal("attack_finished"):
		atk.connect("attack_finished", Callable(self, "_on_attack_finished"))

	get_tree().current_scene.add_child(atk)


func _on_attack_finished():
	_is_attacking = false


func _on_damaged(amount):
	animated_sprite_2d.modulate = Color(1, 0.6, 0.6)
	await get_tree().create_timer(0.15).timeout
	animated_sprite_2d.modulate = Color(1, 1, 1)
	emit_signal("player_damaged", amount)


func _on_health_changed(current, max):
	print("HP: %d / %d" % [current, max])


func _on_died():
	print("Игрок погиб.")
	emit_signal("player_died")
	queue_free()


func apply_knockback(direction: Vector2, force: float):
	knockback_velocity = direction.normalized() * force
