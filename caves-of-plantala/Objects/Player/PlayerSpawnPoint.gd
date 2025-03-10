extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !Global.playerHasBeenSpawned:
		var player = load("res://Objects/Player/Player.tscn").instantiate()
		
		add_child(player)
	
	Global.playerHasBeenSpawned = true
	
	$Sprite2D.visible = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
