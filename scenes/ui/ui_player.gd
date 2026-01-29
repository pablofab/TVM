@tool
extends CanvasLayer

@onready var progress_bar: ProgressBar = $MarginContainer/VBoxContainer/HBoxContainer/ProgressBar
@onready var label = $MarginContainer/VBoxContainer/HBoxContainer/RichTextLabel2

@onready var timer = get_node("/root/Main/Timer")


func _ready() -> void:
	timer.start()
	
	
func time_left_to_live() -> Array:
	var time_left = timer.time_left
	var minute = floor(time_left / 60)
	var second = int(time_left) % 60
	return [minute, second]


func _process(delta: float) -> void:
	label.text = "Tiempo: %02d:%02d" % time_left_to_live()
	
	var node_path = "/root/Main/Players/%s" % owner.get_multiplayer_authority()
	 
	var paint = get_node(node_path).get_paint_amount() 
	
	progress_bar.value = paint
	
