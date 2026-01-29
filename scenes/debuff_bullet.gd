extends Hitbox

@export var speed = 1000
var shooter_id: int  # ID del jugador que disparó el proyectil

signal debuff(player)

# Configurar la bala con el ID del jugador
@rpc("any_peer", "call_local", "reliable")
func setup(id: int) -> void:
	shooter_id = id  # Guardar el ID del jugador que disparó
	set_multiplayer_authority(id)

	
func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	
	
func _physics_process(delta: float) -> void:
	var velocity = speed * transform.x
	position += velocity * delta


func _on_body_entered(body: CharacterBody2D) -> void:
		
	var node_path = "/root/Main/Players/%s" % shooter_id
	var body_id = body.get_multiplayer_authority()
		
	if get_node(node_path) != body:
		_debuff.rpc(body)
		queue_free()
	
	
@rpc("call_local")		
func _debuff(player):
		if not player.is_class("CharacterBody2D")			:
			player = player.get_object_id()

		Debug.log("debuff to: %s" % player)
		emit_signal("debuff", player)
