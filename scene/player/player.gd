extends CharacterBody2D
@onready var animated_sprite_2d = $AnimatedSprite2D

var SPEED = 60
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var direction = movement_vector().normalized()
	velocity = SPEED * direction
	move_and_slide()

func  movement_vector():
	var movement_x = Input.get_action_strength("run_right") - Input.get_action_strength("run_left")
	var movement_y = Input.get_action_strength("run_back") - Input.get_action_strength("run_forward")
	
	if movement_x or movement_y != 0:
		$AnimatedSprite2D.play("run")
	else:
		$AnimatedSprite2D.play("idle")
	
	
	if movement_x > 0:
		$AnimatedSprite2D.flip_h=false
	if movement_x < 0:
		$AnimatedSprite2D.flip_h=true
	
	
	return Vector2(movement_x,movement_y)
