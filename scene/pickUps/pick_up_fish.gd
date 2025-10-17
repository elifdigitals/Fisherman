#extends Node2D
#var SPEED = 100
#var acceleration = .05
#
#
#
#func _on_area_2d_area_entered(area: Area2D) -> void:
	#var player_direction = get_direction_to_player().normalized()
	#var player_distance = get_direction_to_player()
	#var target_velocity = SPEED * player_direction
	#velocity = velocity.lerp(target_velocity, acceleration)
	#move_and_slide()
	#if player_distance.length()<1:
		#queue_free()
#
#
#
#
#
#
#func get_direction_to_player():
	#var player = get_tree().get_first_node_in_group("player") as Node2D
	#var distance_to_player = player.global_position - global_position
	#
	#return distance_to_player
	
	

extends CharacterBody2D

var SPEED = 600
var acceleration = 0.04


var is_moving_to_player = false
var player_node: Node2D = null


func _on_area_2d_area_entered(area: Area2D) -> void:

	if area.is_in_group("player") or area.get_parent().is_in_group("player"):

		player_node = get_tree().get_first_node_in_group("player") as Node2D
		
		if player_node != null:
			is_moving_to_player = true 


func _physics_process(delta: float) -> void:
	if not is_moving_to_player or not is_instance_valid(player_node):

		velocity = velocity.lerp(Vector2.ZERO, acceleration)
		move_and_slide()
		return

	var player_distance_vec = player_node.global_position - global_position
	var distance_to_player = player_distance_vec.length()

	if distance_to_player < 5: 
		queue_free() 
		return 

	var player_direction = player_distance_vec.normalized()
	var target_velocity = SPEED * player_direction

	velocity = velocity.lerp(target_velocity, acceleration)
	
	move_and_slide()
