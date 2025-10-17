extends Area2D

@export var speed := 600
@export var lifetime := 1.8
@export var impact_damage := 10

var direction := Vector2.ZERO
var life_elapsed := 0.0

#@onready var hit_effect_scene = preload("res://scenes/hit_effect.tscn")

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _process(delta):
	position += direction * speed * delta
	life_elapsed += delta
	if life_elapsed >= lifetime:
		queue_free()

func _on_body_entered(body):
	if body and body.has_method("take_damage"):
		body.take_damage(impact_damage)
	queue_free()
