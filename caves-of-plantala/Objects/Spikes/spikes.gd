extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Sprite2D.region_rect.size *= transform.get_scale()
	
	$Sprite2D.global_scale = Vector2(1,1)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
