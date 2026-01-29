extends Node2D

@export var player_scene: PackedScene
@onready var players: Node2D = $Players
@onready var markers: Node2D = $Markers
@onready var timer: Timer = $Timer


@onready var hud: CanvasLayer = $HUD  # Referencia al HUD
@onready var red_score_label: Label = $HUD/HBoxContainer/Label
@onready var green_score_label: Label = $HUD/HBoxContainer/Label2
@onready var blue_score_label: Label = $HUD/HBoxContainer/Label3

const red_tiles = Vector2i(0,1)
const green_tiles = Vector2i(1,1)
const blue_tiles = Vector2i(2,1)

var predefined_colors = [Color(1, 0, 0), Color(0, 1, 0), Color(0, 0, 1)]  # Rojo, Verde, Azul

func _ready() -> void:
	print("Red Score Label: ", red_score_label)  # Verificar si la referencia es válida
	print("Green Score Label: ", green_score_label)
	print("Blue Score Label: ", blue_score_label)
	for i in Game.players.size():
		var player_data = Game.players[i]
		player_data.color = predefined_colors[i % predefined_colors.size()]  # Asignar un color a cada jugador
		var player_inst = player_scene.instantiate()
		players.add_child(player_inst)
		player_inst.setup(player_data)
		player_inst.global_position = markers.get_child(i).global_position
		
	timer.start()
		
	
@rpc("reliable", "any_peer", "call_local")
func update_scores() -> void:
	var tile_map = get_node("/root/Main/Players/TileMap")
	var red_count = tile_map.get_used_cells_by_id(-1, red_tiles, -1).size()
	var green_count = tile_map.get_used_cells_by_id(-1, green_tiles, -1).size()
	var blue_count = tile_map.get_used_cells_by_id(-1, blue_tiles, -1).size()
	# Actualiza los labels con los puntajes
	red_score_label.text = "Red Points: %d" % red_count
	green_score_label.text = "Green Points: %d" % green_count
	blue_score_label.text = "Blue Points: %d" % blue_count
	
func _process(delta: float) -> void:
	update_scores()


func _on_timer_timeout() -> void:
	var tile_map = get_node("/root/Main/Players/TileMap")
	
	var red_count = tile_map.get_used_cells_by_id(-1, red_tiles, -1).size()
	var green_count = tile_map.get_used_cells_by_id(-1, green_tiles, -1).size()
	var blue_count = tile_map.get_used_cells_by_id(-1, blue_tiles, -1).size()
	
	# Llama al RPC para actualizar los puntajes en todos los clientes
	rpc("update_scores", red_count, green_count, blue_count)
	
	print(red_count)
	print(green_count)
	print(blue_count)
	
	get_tree().set_pause(false)

	if red_count > green_count and red_count > blue_count:
		get_tree().change_scene_to_file("res://scenes/red_wins.tscn")
		print("escena_roja")
	elif green_count > red_count and green_count > blue_count:
		get_tree().change_scene_to_file("res://scenes/green_wins.tscn")
		print("escena_verde")
	else:
		get_tree().change_scene_to_file("res://scenes/blue_wins.tscn")
		print("escena_azul")


	
