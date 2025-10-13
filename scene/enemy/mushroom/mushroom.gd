extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var max_speed = 30
var max_distance = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var direction = get_direction_to_player()
	if direction[0] > 0:
		animated_sprite_2d.flip_h=true
	if direction[0] < 0:
		animated_sprite_2d.flip_h=false
	velocity = max_speed * direction
	move_and_slide()


func get_direction_to_player():
	var player = get_tree().get_first_node_in_group("player") as Node2D
	var distance_to_player = player.global_position - global_position
	
	#print(player.global_position - global_position)
	if player != null:
		if distance_to_player.length() > max_distance:
			return distance_to_player.normalized()
		else:
			return Vector2.ZERO
	return Vector2(0,0)
