extends Area2D
signal attack_finished

@export var damage: int = 2
@export var duration: float = 0.12
@export var reach: float = 24.0

var _owner: Node = null
var _dir: Vector2 = Vector2.RIGHT

@onready var timer: Timer = $Timer

func setup(owner: Node, dir: Vector2) -> void:
	if owner == null:
		push_error("Attack.setup: owner == null")
		return
	_owner = owner
	_dir = dir.normalized()
	# позиционируем в мировых координатах относительно владельца
	global_position = _owner.global_position + _dir * reach
	# включаем обнаружение
	monitoring = true
	# настраиваем и запускаем таймер
	if timer:
		timer.stop()
		timer.wait_time = duration
		timer.start()
	else:
		# если таймера нет — просто завершаем через deferred
		call_deferred("_on_timeout")

func _ready() -> void:
	# подключаем сигналы
	connect("body_entered", Callable(self, "_on_body_entered"))
	if timer:
		timer.connect("timeout", Callable(self, "_on_timeout"))

func _on_body_entered(body: Node) -> void:
	# не бьём владельца
	if body == _owner:
		return
	# если у тела есть метод apply_damage — вызываем
	if body.has_method("apply_damage"):
		body.apply_damage(damage)

func _on_timeout() -> void:
	emit_signal("attack_finished")
	queue_free()
