extends Area2D
signal attack_finished

@export var damage: int = 2
@export var duration: float = 0.12
@export var reach: float = 24.0

var _owner: Node
var _dir: Vector2 = Vector2.RIGHT

@onready var timer: Timer = $Timer

func setup(owner: Node, dir: Vector2) -> void:
	_owner = owner
	_dir = dir.normalized()
	position = _dir * reach
	timer.start(duration)

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	timer.connect("timeout", Callable(self, "_on_timeout"))

func _on_body_entered(body: Node) -> void:
	if body == _owner:
		return
	if body.has_method("apply_damage"):
		body.apply_damage(damage)

func _on_timeout():
	emit_signal("attack_finished")
	queue_free()
