extends CharacterBody2D

var speed : float = 150
var health : float = 100:
	set(value):
		health = value
		%Health.value = value
		if health <= 0:
			morir()

var is_dashing : bool = false
var dash_speed : float = 400
var can_dash : bool = true
var dash_duration : float = 0.5
var dash_cooldown : float = 1.0

var nearest_enemy : CharacterBody2D
var nearest_enemy_distance : float = INF

func _physics_process(delta):
	if is_instance_valid(nearest_enemy):
		nearest_enemy_distance = nearest_enemy.separation
		print(nearest_enemy.name)
	else:
		nearest_enemy_distance = INF
	
	var current_speed = dash_speed if is_dashing else speed
	velocity = Input.get_vector("left", "right", "up", "down") * current_speed
	
	if Input.is_action_just_pressed("ui_select") and can_dash: # "ui_select" suele ser Espacio
		start_dash()
	move_and_collide(velocity * delta)

func start_dash():
	is_dashing = true
	can_dash = false
	
	# Duración del sprint
	await get_tree().create_timer(dash_duration).timeout
	is_dashing = false
	
	# Tiempo de recarga
	await get_tree().create_timer(dash_cooldown).timeout
	can_dash = true
	
func take_damage(amount):
	health -= amount
	print(amount)

func morir():
	# Detiene el tiempo y la física de todo el árbol de escenas
	get_tree().paused = true 
	print("El jugador ha muerto. Juego detenido.")
	
func _on_self_damage_body_entered(body):
	take_damage(body.damage)

func _on_timer_timeout() -> void:
	%Collision.set_deferred("disabled", true)
	%Collision.set_deferred("disabled", false)
