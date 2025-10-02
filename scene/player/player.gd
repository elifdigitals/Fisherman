extends CharacterBody2D
@onready var animated_sprite_2d = $AnimatedSprite2D

var SPEED = 200
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var movement = movement_vector()
	var direction = movement.normalized()
	velocity = SPEED * direction
	move_and_slide()

func  movement_vector():
	var movement_x = Input.get_action_strength("run_right") - Input.get_action_strength("run_left")
	var movement_y = Input.get_action_strength("run_back") - Input.get_action_strength("run_forward")
	
	if movement_x > 0:
		$AnimatedSprite2D.flip_h=false
	else:
		$AnimatedSprite2D.flip_h=true
	
	
	return Vector2(movement_x,movement_y)
