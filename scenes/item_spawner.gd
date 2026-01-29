extends Node

@export var item_scene: PackedScene  # Escena del ítem de velocidad
@export var spawn_interval = 5  # Intervalo en segundos entre apariciones
@export var max_items = 36  # Máximo de ítems en el mapa
@export var map_limits = Rect2(Vector2(-860, 3330), Vector2(800, 5440))

@onready var spawn_timer: Timer = $TimerSpawner

var items = []

func _ready():
	# Crear un temporizador para la generación de ítems
	spawn_timer.wait_time = spawn_interval
	spawn_timer.one_shot = false
	spawn_timer.start()
	spawn_timer.connect("timeout", Callable(self, "_spawn_item"))
	
func _spawn_item():
	# Limitar el número de ítems en el mapa
	if items.size() >= max_items:
		return
	# Generar una posición aleatoria dentro del mapa
	var spawn_position = Vector2(
 		randf_range(map_limits.position.x, map_limits.position.x + map_limits.size.x),
 		randf_range(map_limits.position.y, map_limits.position.y + map_limits.size.y)
	)

	var item_instance = item_scene.instantiate()
	item_instance.position = spawn_position
	item_instance.connect("speed_boost_collected", Callable(self, "_on_speed_boost_collected"))
	get_parent().add_child(item_instance)
	items.append(item_instance)
		
func _on_speed_boost_collected(player):
	player.apply_speed_boost()
	items.erase(player)
