extends CharacterBody2D
@onready var animated_sprite_2d = $AnimatedSprite2D


var SPEED = 200
# Called when the node enters the scene tree for the first time.



@export var BulletScene: PackedScene
@export var AttackScene: PackedScene
@export var fire_rate: float = 4.0


# Called every frame. 'delta' is the elapsed time since the previous frame.

var _shoot_cooldown: float = 0.0
var _is_attacking: bool = false

func _ready():
	pass


func _process(delta):
	var movement = movement_vector()
	var direction = movement.normalized()
	velocity = SPEED * direction
	move_and_slide()
	
	if _shoot_cooldown > 0.0:
		_shoot_cooldown = max(0.0, _shoot_cooldown - delta)
	
	if Input.is_action_pressed("shoot") and _shoot_cooldown <= 0.0:
		_shoot()
		_shoot_cooldown = 1.0 / fire_rate
	
	if Input.is_action_just_pressed("attack") and not _is_attacking:
		_start_melee()

func movement_vector() -> Vector2:

	




	var movement_x = Input.get_action_strength("run_right") - Input.get_action_strength("run_left")
	var movement_y = Input.get_action_strength("run_back") - Input.get_action_strength("run_forward")
	
	if movement_x > 0:

		$AnimatedSprite2D.flip_h=false
	else:
		$AnimatedSprite2D.flip_h=true
	
	
	return Vector2(movement_x,movement_y)


	
	return Vector2(movement_x, movement_y)

# --- Стрельба ---
func _shoot() -> void:
	if not BulletScene:
		push_warning("BulletScene не назначен в инспекторе Player.gd")
		return
	
	var bullet = BulletScene.instantiate()
	bullet.global_position = global_position
	
	var dir = (get_global_mouse_position() - global_position).normalized()
	bullet.direction = dir
	
	get_tree().current_scene.add_child(bullet)

# --- Ближняя атака ---
func _start_melee() -> void:
	if not AttackScene:
		push_warning("AttackScene не назначен в инспекторе Player.gd")
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
