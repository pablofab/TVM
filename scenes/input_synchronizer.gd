class_name InputSynchronizer
extends MultiplayerSynchronizer

@export var move_input := 0
@export var move_input2 := 0


func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		move_input = Input.get_axis("move_left", "move_right")
		move_input2 = Input.get_axis("move_up", "move_down")
