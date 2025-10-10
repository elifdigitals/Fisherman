extends Node2D

signal died
signal damaged(amount)
signal healed(amount)
signal health_changed(current, max)

@export var max_health: int = 100
@export var regen_rate: float = 0.0
@export var invincible_time: float = 0.4
@export var flash_on_hit: bool = true
@export var death_effect_scene: PackedScene
@export var hit_sound: AudioStream
@export var death_sound: AudioStream

var current_health: int
var _invincible_timer: float = 0.0
var _is_dead: bool = false
var _sprite: Sprite2D

func _ready():
	current_health = max_health
	_sprite = get_parent().get_node_or_null("AnimatedSprite2D")
	emit_signal("health_changed", current_health, max_health)

func _process(delta):
	if _is_dead:
		return
	if _invincible_timer > 0:
		_invincible_timer -= delta
	if regen_rate > 0 and current_health < max_health:
		current_health = min(max_health, current_health + regen_rate * delta)
		emit_signal("health_changed", current_health, max_health)

func apply_damage(amount: int, knockback_dir: Vector2 = Vector2.ZERO, knockback_force: float = 100.0):
	if _is_dead or _invincible_timer > 0:
		return
	current_health -= amount
	emit_signal("damaged", amount)
	emit_signal("health_changed", current_health, max_health)
	_invincible_timer = invincible_time

	if hit_sound:
		_play_sound(hit_sound)

	if flash_on_hit and _sprite:
		_flash()

	if get_parent().has_method("apply_knockback") and knockback_dir != Vector2.ZERO:
		get_parent().apply_knockback(knockback_dir, knockback_force)

	if current_health <= 0:
		_die()

func heal(amount: int):
	if _is_dead:
		return
	current_health = clamp(current_health + amount, 0, max_health)
	emit_signal("healed", amount)
	emit_signal("health_changed", current_health, max_health)

func _flash():
	if not _sprite:
		return
	var tween = create_tween()
	tween.tween_property(_sprite, "modulate", Color(1, 0.3, 0.3), 0.05)
	tween.tween_property(_sprite, "modulate", Color(1, 1, 1), 0.15)

func _die():
	if _is_dead:
		return
	_is_dead = true
	if death_sound:
		_play_sound(death_sound)
	if death_effect_scene:
		var effect = death_effect_scene.instantiate()
		effect.global_position = global_position
		get_tree().current_scene.add_child(effect)
	emit_signal("died")
	if get_parent():
		get_parent().queue_free()

func _play_sound(sound: AudioStream):
	var player = AudioStreamPlayer2D.new()
	player.stream = sound
	get_tree().current_scene.add_child(player)
	player.global_position = global_position
	player.play()
	player.connect("finished", Callable(player, "queue_free"))
