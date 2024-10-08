extends Node2D
class_name CellHighlight

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationPlayer.play("blink")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _draw() -> void:
	draw_polyline(
		[Vector2(-8, -8), Vector2(8, -8), Vector2(8, 8), Vector2(-8, 8), Vector2(-8, -8)],
		Color.RED,
		2.0,
	)

func set_texture(tx: Texture):
	$Sprite2D.texture = tx
