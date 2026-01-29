extends Control
@onready var volver = $PanelContainer/PanelContainer/HBoxContainer/Volver

# Called when the node enters the scene tree for the first time.
func _ready():
	volver.pressed.connect(_on_volver_pressed)
	
func _on_volver_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/lobby.tscn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
