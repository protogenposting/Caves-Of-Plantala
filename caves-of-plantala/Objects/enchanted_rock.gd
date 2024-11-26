extends Node2D

@onready var endPoint = $EndPoint

@export var endPointPos : Vector2 = Vector2(0,0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	endPoint.position = endPointPos
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Player")):
		print("started")
		var tween = get_tree().create_tween()
		tween.tween_property($Body, "position", $EndPoint.position, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		tween.tween_property($Body, "position", Vector2(), 3)
	pass # Replace with function body.
