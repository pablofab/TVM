extends CharacterBody2D
@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var animation = $AnimationPlayer
@onready var wallpass_timer: Timer = $WallpassTimer
@onready var wallpass_cooldown: Timer = $WallpassCooldown
@onready var debuff_timer: Timer = $DebuffTimer


var speed = 450
var boosted_speed = 600
var is_boosted = false
var can_use_wallpass = true
var has_debuff = false
var acceleration = 1500
var paint_amount = 100

var player

var dash_speed = 1200 
var dash_duration = 0.25 
var dash_cooldown = 5.0  
var is_dashing = false
var can_dash = true
var dash_time_left = 0.0
var dash_direction = Vector2.ZERO
var dash_cooldown_left = 0.0

@onready var gun: Node2D = $Gun

@onready var label: Label = $Label
@onready var input_synchronizer: InputSynchronizer = $InputSynchronizer
@onready var camera: Camera2D = $Camera2D
@onready var paint_timer: Timer = $PaintTimer


func _ready():
	paint_timer.connect("timeout", Callable(self, "collect_paint_jar"))
	

func _process(delta: float) -> void:
	if is_multiplayer_authority():
		gun.rotation = gun.global_position.direction_to(get_global_mouse_position()).angle()
				

func setup(player_data: Statics.PlayerData) -> void:
	name = str(player_data.id)
	set_multiplayer_authority(player_data.id)
	input_synchronizer.set_multiplayer_authority(player_data.id, false)
	label.text = player_data.name
	player = player_data
		
	# Solo activar la cámara si este jugador es controlado
	# Activar la cámara solo si este nodo es del jugador local
	# Activar la cámara solo si este nodo es del jugador local
	if is_multiplayer_authority():
		camera.make_current()  # Activar la cámara para el jugador local
		
		
	
		
		
func _input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		if event.is_action_pressed("test"):
			test.rpc_id(1)
		if event.is_action_pressed("dash") and dash_cooldown_left <= 0.0:
			start_dash()
		if event.is_action_pressed("pass_wall"):
			enable_wall_pass()
			
			
func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():  #solo si no se usa el synchronizer
		if is_dashing:
			dash_time_left -= delta
			if dash_time_left > 0:
				# Move in the dash direction with high speed
				velocity = dash_direction * dash_speed
			else:
				# End the dash
				is_dashing = false
				dash_cooldown_left = dash_cooldown
		else: 
			var move_input = Input.get_axis("move_left", "move_right")   #comentar si se usa sync
			var move_input2 = Input.get_axis("move_up", "move_down")  #comentar si se usa sync
			
			velocity.x = move_toward(velocity.x, speed * move_input, acceleration * delta)
			velocity.y = move_toward(velocity.y, speed * move_input2, acceleration * delta)
			
			
			send_position.rpc(position, velocity)  #comentar si se usa sync
			if dash_cooldown_left > 0:
				dash_cooldown_left -= delta
			else:
				can_dash = true
			
	update_animation()
	move_and_slide()  #si el send_position está, el move_and_slide debe estar afuera del if

					
func apply_speed_boost():
	printt("spd")
	if not is_boosted:
		is_boosted = true
		speed = boosted_speed
		# Crear un temporizador para controlar la duración del boost
		var timer = Timer.new()
		timer.wait_time = 7.5  # Duración del aumento de velocidad
		timer.one_shot = true
		add_child(timer)
		timer.start()
		# Esperar a que el temporizador finalice
		await timer.timeout
		
		# Restablecer la velocidad original y eliminar el temporizador
		speed = 450
		is_boosted = false
		timer.queue_free()
		

func collect_paint_jar():
	if paint_amount < 100:
		paint_amount += 10
		printt("paint_jar_collected")
		printt(paint_amount)
	


func reduce_paint_amount():
	if paint_amount > 0:
		paint_amount -= 10
		printt("paint_amount_reduced")
		printt(paint_amount)


func get_paint_amount():
	return paint_amount


@rpc("authority", "call_local", "unreliable")		
func test():
	Debug.log("test %s" % player.name)


@rpc
func send_position(pos: Vector2, vel: Vector2) -> void:
	position = lerp(position, pos, 0.5)
	velocity = lerp(velocity, vel, 0.5)
	
func start_dash() -> void:
	can_dash = false
	dash_direction = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down")).normalized()
	if dash_direction != Vector2.ZERO:
		is_dashing = true
		dash_time_left = dash_duration
		dash_cooldown_left = dash_cooldown


	
@rpc		
func update_animation():
	if velocity.length() == 0:

		animation.stop()
	else:
		var direction = "Down"
		if velocity.x > 0: # Direction = right
			sprite.rotation = deg_to_rad(90)
			collision.rotation = deg_to_rad(90)
			if velocity.y < 0:
				sprite.rotation = deg_to_rad(45)
				collision.rotation = deg_to_rad(45)
			elif velocity.y > 0:
				sprite.rotation = deg_to_rad(135)
				collision.rotation = deg_to_rad(135)
		elif velocity.x < 0: # Direction = left
			sprite.rotation = deg_to_rad(-90)
			collision.rotation = deg_to_rad(-90)
			if velocity.y < 0:
				sprite.rotation = deg_to_rad(-45)
				collision.rotation = deg_to_rad(-45)
			if velocity.y > 0:
				sprite.rotation = deg_to_rad(-135)
				collision.rotation = deg_to_rad(-135)
		elif velocity.y > 0: # Direction = down
			sprite.rotation = deg_to_rad(180)
			collision.rotation = deg_to_rad(180)
		elif velocity.y < 0: # Direction = down
			sprite.rotation = deg_to_rad(0)
			collision.rotation = deg_to_rad(0)
		animation.play("walk")


func debuff():
	
	printt("!!")
	
	has_debuff = true
	
	speed = 50
	debuff_timer.wait_time = 10.0  # Duración del efecto
	debuff_timer.start()
	# Esperar a que el temporizador termine
	await debuff_timer.timeout
	
	speed = 600

	has_debuff = false
		
		
func enable_wall_pass():
	if not can_use_wallpass:
		printt("Wall pass is on cooldown!")
		return  # Salir si la habilidad está en enfriamiento
	
	can_use_wallpass = false  # Deshabilitar la habilidad hasta que termine el enfriamiento

	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)

	
	printt("Wall pass enabled")
	
	# Iniciar el temporizador para la duración del efecto
	wallpass_timer.wait_time = 7.5  # Duración del efecto
	wallpass_timer.start()
	
	# Esperar a que el temporizador termine
	await wallpass_timer.timeout
	
	set_collision_layer_value(1, true)
	set_collision_mask_value(1, true)
 

	printt("Wall pass disabled")
	
	# Resolver si el jugador está dentro de una pared
	if is_inside_wall():
		resolve_position()
	
	# Iniciar el temporizador de enfriamiento
	wallpass_cooldown.wait_time = 30.0  # Duración del enfriamiento
	wallpass_cooldown.start()
	await wallpass_cooldown.timeout
	
	can_use_wallpass = true  # Habilidad disponible nuevamente
	printt("Wall pass is ready!")
		
		
func is_inside_wall() -> bool:
	var space_state = get_world_2d().direct_space_state
	# Crear parámetros de consulta
	var query = PhysicsPointQueryParameters2D.new() #
	query.position = position
	query.collision_mask = 1  # capa de las paredes   
	# Realizar la consulta
	var result = space_state.intersect_point(query)
	return result.size() > 0
	
func resolve_position():
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.collision_mask = 1  # capa de las paredes
	
	# Explorar puntos cercanos
	for x_offset in [-1, 0, 1]:
		for y_offset in [-1, 0, 1]:
			if x_offset == 0 and y_offset == 0:
				continue  # No comprobar la posición actual
			
			var test_pos = position + Vector2(x_offset, y_offset) * 10  # Cambia 10 según el tamaño del área a explorar
			query.position = test_pos
			
			# Verificar si el punto es válido
			if space_state.intersect_point(query).size() == 0:
				position = test_pos
				return  # Terminar la búsqueda al encontrar un punto válido

	
