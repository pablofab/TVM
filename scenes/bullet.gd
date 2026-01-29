extends Hitbox

const RED_WALL_TILE_ATLAS_POS = Vector2i(0,1)
const GREEN_WALL_TILE_ATLAS_POS = Vector2i(1,1)
const BLUE_WALL_TILE_ATLAS_POS = Vector2i(2,1)
const GRAY_WALL_TILE_ATLAS_POS = Vector2i(1,0)

@export var speed = 750
var shooter_id: int  # ID del jugador que disparó el proyectil

# Configurar la bala con el ID del jugador
@rpc("any_peer", "call_local", "reliable")
func setup(id: int) -> void:
	shooter_id = id  # Guardar el ID del jugador que disparó
	set_multiplayer_authority(id)

	
func _ready():
	
	body_entered.connect(_body_entered)
	
# Mover la bala manualmente

func _physics_process(delta: float) -> void:
	var velocity = speed * transform.x
	position += velocity * delta

# Detectar colisiones con cuerpos (como las paredes)


func _body_entered(body: TileMapLayer) -> void:
	
	
	
	var tile_map = get_node("/root/Main/Players/TileMap")
	var cell_pos = tile_map.local_to_map(global_position)
	
	# Llamar a la función RPC para pintar la celda con el color del jugador que disparó
	paint_tile_rpc(cell_pos, Game.get_player(shooter_id).color)
	
	queue_free()  # Destruir el proyectil después de la colisión
	

# Función RPC para sincronizar el color en todos los jugadores

@rpc("call_remote")
func paint_tile_rpc(cell_pos: Vector2i, color: Color) -> void:
	var tile_map = get_node("/root/Main/Players/TileMap")
	if tile_map.get_cell_atlas_coords(cell_pos) == RED_WALL_TILE_ATLAS_POS or \
	tile_map.get_cell_atlas_coords(cell_pos) == GREEN_WALL_TILE_ATLAS_POS or \
	tile_map.get_cell_atlas_coords(cell_pos) == BLUE_WALL_TILE_ATLAS_POS or \
	tile_map.get_cell_atlas_coords(cell_pos) == GRAY_WALL_TILE_ATLAS_POS:
		if color ==  Color(1, 0, 0):
			tile_map.set_cell(cell_pos, 1, RED_WALL_TILE_ATLAS_POS, 0)
		elif color == Color(0, 1, 0):
			tile_map.set_cell(cell_pos, 1, GREEN_WALL_TILE_ATLAS_POS, 0)  
		else:
			tile_map.set_cell(cell_pos, 1, BLUE_WALL_TILE_ATLAS_POS, 0)
			
				
		
		
		
