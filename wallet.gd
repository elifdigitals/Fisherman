extends Node

var coins: int = 0
signal coins_changed(new_value)

func add_coins(amount: int):
	if amount <= 0:
		return
	coins += amount
	emit_signal("coins_changed", coins)
	print("💰 Coins: %d" % coins)

func spend_coins(amount: int) -> bool:
	if coins >= amount:
		coins -= amount
		emit_signal("coins_changed", coins)
		return true
	else:
		print("Недостаточно монет для покупки!")
		return false
		
		
		
		#func chase_target(delta, dist):
	#var dir = (target.global_position - global_position).normalized()
	#velocity = dir * move_speed
	#move_and_slide()
	#sprite.flip_h = dir.x < 0
	#if dist <= attack_range:
		#try_attack()
#
#func try_attack():
	#if attack_timer <= 0 and not hp.dead:
		#if target and target.has_method("take_damage"):
			#target.take_damage(attack_damage)
		#attack_timer = attack_interval
		#sprite.play("attack")
#
#func _on_damaged(amount):
	#sprite.modulate = Color(1, 0.5, 0.5)
	#await get_tree().create_timer(0.1).timeout
	#sprite.modulate = Color(1, 1, 1)
#
#func _on_death():
	#sprite.play("death")
	#spawn_coins()
	#await get_tree().create_timer(0.6).timeout
	#queue_free()
#
#func spawn_coins():
	#if not CoinScene:
		#return
	#var amount = randi_range(coin_drop_min, coin_drop_max)
	#var coins_to_spawn = int(amount / 10)
	#for i in range(coins_to_spawn):
		#var coin = CoinScene.instantiate()
		#coin.global_position = global_position + Vector2(randf() * 16 - 8, randf() * 16 - 8)
		#get_tree().current_scene.add_child(coin)
