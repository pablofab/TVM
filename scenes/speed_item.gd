extends Area2D

signal speed_boost_collected(player)

func _ready():
	# Conectar la señal de colisión
	connect("body_entered", Callable(self, "_on_body_entered"))
	
func _on_body_entered(body):
	if body.is_in_group("Player"):
		emit_signal("speed_boost_collected", body)  # Aquí emitimos la señal
		queue_free()  # Eliminar el ítem del mapa
