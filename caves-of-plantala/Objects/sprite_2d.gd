extends Sprite2D

var startPos : Vector2

@export var shake : float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	startPos = position
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position = startPos + Vector2(shake*randf_range(-1,1),shake*randf_range(-1,1))
	pass
