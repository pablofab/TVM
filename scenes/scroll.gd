extends ScrollContainer

@onready var scroll_container = $"."
var scroll_speed = 1
var scroll_finish = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scroll_container.scroll_vertical = 0
	#scroll_container.connect("scroll_ended", self, "_on_scroll_ended")
	

func _on_scroll_ended():
	print("ola")

# Called every frame. 'delta' is the elapsed time since the previous frame
func _physics_process(delta: float) -> void:
	var last_scroll = scroll_container.scroll_vertical
	scroll_container.scroll_vertical += scroll_speed
	var new_scroll = scroll_container.scroll_vertical
	if last_scroll == new_scroll:
		#scroll_finish = true
		print("me fui al main menu")
		_to_main_menu()
		
		
func _to_main_menu():
	print("verifico el coso")
	if not scroll_finish:
		scroll_finish = true
		set_physics_process(false)
		await get_tree().create_timer(3).timeout
		print("termineeee")
		get_tree().change_scene_to_file("res://scenes/lobby.tscn")
	
