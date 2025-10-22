extends Area2D

signal attack_started(owner)
signal attack_finished
signal target_hit(target, damage)

@export var damage: int = 2
@export var duration: float = 0.12
@export var reach: float = 28.0
@export var knockback_force: float = 80.0
@export var impact_effect: PackedScene
@export var color_modulate: Color = Color(1, 1, 1)
@export var debug_enabled: bool = false

var _owner: Node = null
var _dir: Vector2 = Vector2.RIGHT
var _has_hit: bool = false
var _start_time: float = 0.0
var _active: bool = false

@onready var timer: Timer = $Timer
@onready var sprite: Sprite2D = $Sprite2D if has_node("Sprite2D") else null

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))
	if timer:
		timer.connect("timeout", Callable(self, "_on_timeout"))
	if sprite:
		sprite.modulate = color_modulate
	set_process(debug_enabled)

func setup(owner: Node, dir: Vector2) -> void:
	if owner == null:
		push_warning("⚠️ Attack.setup: owner == null, cancelling attack.")
		return
	_owner = owner
	_dir = dir.normalized()
	_start_time = Time.get_ticks_msec() / 1000.0
	_active = true
	global_position = _owner.global_position + _dir * reach
	rotation = _dir.angle()
	monitoring = true
	monitorable = true
	if timer:
		timer.stop()
		timer.wait_time = duration
		timer.start()
	else:
		call_deferred("_on_timeout")
	emit_signal("attack_started", _owner)
	if debug_enabled:
		print("[ATTACK] Created attack from %s (damage=%d, reach=%.1f)" % [_owner.name, damage, reach])

func _process(_delta):
	if not debug_enabled:
		return
	if Engine.is_editor_hint():
		return
	# Простая отладочная визуализация
	var color = Color(1, 0, 0, 0.4) if _active else Color(0, 1, 0, 0.2)
	var rect = Rect2(Vector2(-4, -4), Vector2(8, 8))


func _on_body_entered(body: Node) -> void:
	if not _active or _has_hit:
		return
	if body == _owner:
		return
	if not is_instance_valid(body):
		return

	if body.has_method("apply_damage"):
		body.apply_damage(damage)
		emit_signal("target_hit", body, damage)
		if debug_enabled:
			print("[ATTACK] Hit %s for %d damage" % [body.name, damage])
		if impact_effect:
			var effect = impact_effect.instantiate()
			effect.global_position = global_position
			get_tree().current_scene.add_child(effect)
		_apply_knockback(body)
		_has_hit = true

func _apply_knockback(body: Node):
	if not body.has_method("apply_impulse"):
		return
	if knockback_force <= 0:
		return
	var knock_dir = (body.global_position - global_position).normalized()
	body.apply_impulse(knock_dir * knockback_force)

func _on_timeout() -> void:
	_active = false
	emit_signal("attack_finished")
	if debug_enabled:
		print("[ATTACK] Attack finished at t=%.2f" % ((Time.get_ticks_msec() / 1000.0) - _start_time))
	queue_free()
