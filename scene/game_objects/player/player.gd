#extends CharacterBody2D
#
#@onready var health_component = $HealthComponent
#@onready var grace_period = $GracePeriod
#@onready var progress_bar = $ProgressBar
#@onready var ability_manager = $AbilityManager
#@onready var animated_sprite_2d = $AnimatedSprite2D
#
#var lastDirection = "S"
#var max_speed = 125
#var acceleration = .15
#var enemies_colliding = 0
#var is_attacking = false
#
#func _ready():
	#health_component.died.connect(on_died)
	#health_component.health_changed.connect(on_health_changed)
	#Global.ability_upgrade_added.connect(on_ability_upgrade_added)
	#animated_sprite_2d.animation_finished.connect(_on_animation_finished)
	#health_update()
#
#
##func _process(delta):
	##var direction = movement_vector().normalized()
	##var target_velocity = max_speed * direction
	##
	##velocity = velocity.lerp(target_velocity, acceleration)
	##move_and_slide()
	##
	##if direction.x != 0 || direction.y != 0:
		##animated_sprite_2d.play("run")
	##else:
		##animated_sprite_2d.play("idle")
		##
	##var face_sign = sign(direction.x)
	##if face_sign != 0:
		##animated_sprite_2d.scale.x = face_sign
#func _process(delta):
	#var direction = movement_vector().normalized()
	#var target_velocity = max_speed * direction
	#velocity = velocity.lerp(target_velocity, acceleration)
	#move_and_slide()
	#
##func movement_vector():
	##var movement_x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	##var movement_y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	##return Vector2(movement_x, movement_y)
#
#func  movement_vector():
	#var movement_x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	#var movement_y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	#
	#if movement_x > 0:
		#$AnimatedSprite2D.play("run_right")
		#$AnimatedSprite2D.flip_h=false
		#lastDirection = "D"
	#elif movement_x < 0:
		#$AnimatedSprite2D.play("run_right")
		#$AnimatedSprite2D.flip_h=true
		#lastDirection = "A"
#
	#if movement_y > 0 and movement_x == 0:
		#$AnimatedSprite2D.play("run")
		#lastDirection = "S"
#
	#elif movement_y < 0 and movement_x == 0:
		#$AnimatedSprite2D.play("run_back")
		#lastDirection = "W"
#
	#if  movement_x == 0 and movement_y == 0:
		#if lastDirection == "A":
			#$AnimatedSprite2D.play("idle_right")
			#$AnimatedSprite2D.flip_h=true
		#elif lastDirection == "W":
			#$AnimatedSprite2D.play("idle_back")
		#elif lastDirection == "S":
			#$AnimatedSprite2D.play("idle")
		#elif lastDirection == "D":
			#$AnimatedSprite2D.play("idle_right")
			#$AnimatedSprite2D.flip_h=false
	#
	#return Vector2(movement_x,movement_y)
	#
#func check_if_damaged():
	#if enemies_colliding == 0 || !grace_period.is_stopped():
		#return
	#health_component.take_damage(1)
	#grace_period.start()
	#
	#
#func health_update():
	#progress_bar.value = health_component.get_health_value()
	#
#func _on_player_hurt_box_area_entered(area):
	#enemies_colliding += 1
	#check_if_damaged()
#
#
#func _on_player_hurt_box_area_exited(area):
	#enemies_colliding -= 1
#
#
#func on_died():
	#queue_free()
	#
#
#func on_health_changed():
	#health_update()
#
#
#func _on_grace_period_timeout():
	#check_if_damaged()
#
#
#func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	#if not upgrade is NewAbility:
		#return
		#
	#var new_ability = upgrade as NewAbility
	#ability_manager.add_child(new_ability.new_ability_scene.instantiate())
	#
	
extends CharacterBody2D

@onready var health_component = $HealthComponent
@onready var grace_period = $GracePeriod
@onready var progress_bar = $ProgressBar
@onready var ability_manager = $AbilityManager
@onready var animated_sprite_2d = $AnimatedSprite2D

var lastDirection = "S"
var max_speed = 125
var acceleration = .15
var enemies_colliding = 0

# 1. Добавляем флаг состояния атаки
var is_attacking = false

func _ready():
	health_component.died.connect(on_died)
	health_component.health_changed.connect(on_health_changed)
	Global.ability_upgrade_added.connect(on_ability_upgrade_added)
	
	# 2. Подключаем сигнал окончания анимации спрайта
	# Это критически важно, чтобы персонаж "вышел" из состояния атаки
	animated_sprite_2d.animation_finished.connect(_on_animation_finished)
	
	health_update()

func _process(delta):
	# Пример ввода для теста (потом можно убрать или перенести в AbilityManager)
	if Input.is_action_just_pressed("right_click"): # Убедитесь, что действие добавлено в Input Map
		trigger_attack()
		
	var direction = movement_vector().normalized()
	
	# Если мы атакуем, часто мы хотим замедлить или остановить персонажа.
	# Если вы хотите двигаться во время удара, уберите проверку "if !is_attacking"
	var target_velocity = Vector2.ZERO
	if !is_attacking:
		target_velocity = max_speed * direction
	
	velocity = velocity.lerp(target_velocity, acceleration)
	move_and_slide()

# 3. Публичная функция для запуска атаки
# Вызывайте её откуда угодно: из Input, из AbilityManager и т.д.
func trigger_attack():
	if is_attacking:
		return # Не прерываем текущую атаку
		
	is_attacking = true
	
	# Поворачиваем спрайт в сторону мыши перед ударом (опционально)
	# Или используем lastDirection для выбора анимации
	var mouse_pos = get_global_mouse_position()
	if mouse_pos.x < global_position.x:
		animated_sprite_2d.flip_h = true
	else:
		animated_sprite_2d.flip_h = false
		
	animated_sprite_2d.play("hit") # Убедитесь, что анимация называется "hit"

func movement_vector():
	var movement_x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var movement_y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	
	# 4. БЛОКИРОВКА АНИМАЦИЙ
	# Если идет атака, мы НЕ меняем анимацию на бег/стойку
	if is_attacking:
		return Vector2(movement_x, movement_y)

	# Логика анимации движения (выполняется только если не атакуем)
	if movement_x > 0:
		$AnimatedSprite2D.play("run_right")
		$AnimatedSprite2D.flip_h = false
		lastDirection = "D"
	elif movement_x < 0:
		$AnimatedSprite2D.play("run_right")
		$AnimatedSprite2D.flip_h = true
		lastDirection = "A"

	if movement_y > 0 and movement_x == 0:
		$AnimatedSprite2D.play("run")
		lastDirection = "S"
	elif movement_y < 0 and movement_x == 0:
		$AnimatedSprite2D.play("run_back")
		lastDirection = "W"

	if movement_x == 0 and movement_y == 0:
		if lastDirection == "A":
			$AnimatedSprite2D.play("idle_right")
			$AnimatedSprite2D.flip_h = true
		elif lastDirection == "W":
			$AnimatedSprite2D.play("idle_back")
		elif lastDirection == "S":
			$AnimatedSprite2D.play("idle")
		elif lastDirection == "D":
			$AnimatedSprite2D.play("idle_right")
			$AnimatedSprite2D.flip_h = false
	
	return Vector2(movement_x, movement_y)

# 5. Обработка окончания анимации
func _on_animation_finished():
	if animated_sprite_2d.animation == "hit":
		is_attacking = false
		# Сразу обновляем анимацию покоя/бега, чтобы не ждать следующего кадра
		movement_vector()

# ... Остальной ваш код (check_if_damaged, health_update и т.д.) ...
func check_if_damaged():
	if enemies_colliding == 0 || !grace_period.is_stopped():
		return
	health_component.take_damage(1)
	grace_period.start()

func health_update():
	progress_bar.value = health_component.get_health_value()

func _on_player_hurt_box_area_entered(area):
	enemies_colliding += 1
	check_if_damaged()

func _on_player_hurt_box_area_exited(area):
	enemies_colliding -= 1

func on_died():
	queue_free()

func on_health_changed():
	health_update()

func _on_grace_period_timeout():
	check_if_damaged()

func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if not upgrade is NewAbility:
		return
	var new_ability = upgrade as NewAbility
	ability_manager.add_child(new_ability.new_ability_scene.instantiate())
	
