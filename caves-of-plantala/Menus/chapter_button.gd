extends Button

@export var levelName : String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_pressed() -> void:
	get_tree().get_root().change_scene_to_file("res://Levels/"+levelName+".tscn")
	get_tree().get_root().free()
	pass # Replace with function body.
