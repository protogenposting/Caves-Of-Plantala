extends Area2D

@export var spawn : Node2D = self

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var areas = get_overlapping_areas()
	
	for i in areas:
		if i.is_in_group("SpawnPoint"):
			spawn = i
	pass


func _on_area_entered(area: Area2D) -> void:
	pass # Replace with function body.
