extends CharacterBody2D
@onready var animated_sprite_2d = $AnimatedSprite2D

var SPEED = 60
#up, left, down, right = WASD
var lastDirection = "S"

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var direction = movement_vector().normalized()
	velocity = SPEED * direction
	move_and_slide()
	print(direction)
	

func  movement_vector():
	var movement_x = Input.get_action_strength("run_right") - Input.get_action_strength("run_left")
	var movement_y = Input.get_action_strength("run_back") - Input.get_action_strength("run_forward")
	
	#if movement_x or movement_y != 0:
		#$AnimatedSprite2D.play("run")
	#else:
		#$AnimatedSprite2D.play("idle")
	
	
	if movement_x > 0:
		$AnimatedSprite2D.play("run_right")
		$AnimatedSprite2D.flip_h=false
		lastDirection = "D"
	if movement_x < 0:
		$AnimatedSprite2D.play("run_right")
		$AnimatedSprite2D.flip_h=true
		lastDirection = "A"
	
	if movement_y > 0 and movement_x == 0:
		$AnimatedSprite2D.play("run")
		lastDirection = "S"
		
	if movement_y < 0 and movement_x == 0:
		$AnimatedSprite2D.play("run_forward")
		lastDirection = "W"
		
	if  movement_x == 0 and movement_y == 0:
		if lastDirection == "A":
			$AnimatedSprite2D.play("idle_right")
			$AnimatedSprite2D.flip_h=true
		if lastDirection == "W":
			$AnimatedSprite2D.play("idle_forward")
		if lastDirection == "S":
			$AnimatedSprite2D.play("idle")
		if lastDirection == "D":
			$AnimatedSprite2D.play("idle_right")
			$AnimatedSprite2D.flip_h=false
			
		
	
	return Vector2(movement_x,movement_y)
