extends Node2D

@onready var anim = $AnimatedSprite2D
@export var duration := 0.3

func _ready():
	anim.play("hit")
	await get_tree().create_timer(duration).timeout
	queue_free()
