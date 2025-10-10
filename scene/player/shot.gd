extends Area2D

var direction: Vector2 = Vector2.RIGHT

@export var speed: float = 600.0
@export var lifetime: float = 2.0
@export var damage: int = 1

var _life_timer: float = 0.0

func _ready() -> void:
	monitoring = true
	_life_timer = lifetime
	connect("body_entered", Callable(self, "_on_body_entered"))

func _physics_process(delta: float) -> void:
	# Двигаем пулю по миру
	global_position += direction * speed * delta
	
	# Ограничение времени жизни
	_life_timer -= delta
	if _life_timer <= 0:
		queue_free()

func _on_body_entered(body: Node) -> void:
	# Не наносим урон себе
	if body == get_parent():
		return
	
	if body.has_method("apply_damage"):
		body.apply_damage(damage)
	queue_free()
