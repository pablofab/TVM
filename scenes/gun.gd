extends Node2D

@export var bullet_scene: PackedScene
@export var bullet_scene2: PackedScene
@onready var marker_2d: Marker2D = $Marker2D
@onready var bullet_spawner: MultiplayerSpawner = $BulletSpawner
@onready var fire_timer: Timer = $FireTimer
@onready var triple_shot_timer: Timer = $TripleShotTimer
@onready var debuff_shot_timer: Timer = $DebuffShotTimer
@onready var debuff_bullet_spawner: MultiplayerSpawner = $DebuffBulletSpawner


var can_fire: bool = true # Variable para controlar si el arma puede disparar
var can_fire_triple: bool = true
var can_fire_debuff: bool = true

func _ready() -> void:
	fire_timer.wait_time = 0.25 # Configura el tiempo de espera (0.5 segundos)
	fire_timer.one_shot = true # Dispara solo una vez hasta que se reinicie
	fire_timer.connect("timeout", Callable(self, "_on_fire_timer_timeout")) # Usa un Callable
	
	triple_shot_timer.wait_time = 7.5
	triple_shot_timer.one_shot = true
	triple_shot_timer.connect("timeout", Callable(self, "_on_triple_shot_timer_timeout"))
	
	debuff_shot_timer.wait_time = 30.0
	debuff_shot_timer.one_shot = true
	debuff_shot_timer.connect("timeout", Callable(self, "_on_debuff_shot_timer_timeout"))
	
	

func _input(event: InputEvent) -> void:
	if owner.is_multiplayer_authority():
		if event.is_action_pressed("fire"):
			var node_path = "/root/Main/Players/%s" % owner.get_multiplayer_authority()
			if can_fire and not get_node(node_path).has_debuff:  # Verifica si se puede disparar normalmente
				fire()
				can_fire = false
				fire_timer.start()

		if event.is_action_pressed("fire_alt"):  # Acción para disparo alternativo
			if can_fire_debuff:  # Verifica si el disparo debuff está disponible
				fire_debuff()
				can_fire_debuff = false
				debuff_shot_timer.start()  # Inicia el enfriamiento del disparo debuff
			
		if event.is_action_pressed("fire_triple"):  # Acción para disparo triple
			if can_fire_triple:  # Verifica si el disparo triple está disponible
				fire_triple()
				can_fire_triple = false
				triple_shot_timer.start()  # Inicia el enfriamiento del disparo triple
		
		

func fire() -> void:
	if not bullet_scene:
		Debug.log("No bullet provided")
		return
	var node_path = "/root/Main/Players/%s" % owner.get_multiplayer_authority()
	if get_node(node_path).get_paint_amount() > 0:
		spawn_bullet(global_rotation)  # Llama a una función que crea la bala
		get_node(node_path).reduce_paint_amount()
	
	
func fire_triple() -> void:
	if not bullet_scene:
		Debug.log("No bullet provided")
		return
	# Dispara balas alrededor
	spawn_bullet(global_rotation)           # Bala central
	spawn_bullet(global_rotation + 0.2)     # Bala ligeramente a la derecha
	spawn_bullet(global_rotation - 0.2)     # Bala ligeramente a la izquierda


func fire_debuff() -> void:
	if not bullet_scene2:
		Debug.log("No debuff bullet provided")
		return
			
	spawn_bullet2(global_rotation)



func spawn_bullet(rotation: float) -> void:
	var bullet_inst = bullet_scene.instantiate()
	bullet_inst.global_position = marker_2d.global_position
	bullet_inst.global_rotation = rotation
	bullet_spawner.add_child(bullet_inst, true)
	bullet_inst.setup.rpc(owner.get_multiplayer_authority())
	
	
func spawn_bullet2(rotation: float) -> void:
	var bullet_inst2 = bullet_scene2.instantiate()
	bullet_inst2.global_position = marker_2d.global_position
	bullet_inst2.global_rotation = rotation
	bullet_inst2.connect("debuff", Callable(self, "_on_debuff"))
	debuff_bullet_spawner.add_child(bullet_inst2, true)
	bullet_inst2.setup.rpc(owner.get_multiplayer_authority())	


# Función que se llama cuando el temporizador termina su cuenta
func _on_fire_timer_timeout() -> void:
	can_fire = true # Permite disparar nuevamente

func _on_triple_shot_timer_timeout() -> void:
	can_fire_triple = true
	printt("Triple shot is ready!")

func _on_debuff_shot_timer_timeout() -> void:
	can_fire_debuff = true
	printt("Debuff shot is ready!")

func _on_debuff(player):
	player.debuff()
