extends Selection

class_name PaintSelection

var selected: Dictionary = {}

func _add_cell(pos: Vector2i):
	selected[pos] = true

func _draw() -> void:
	if _cancelled:
		return

	for pos in selected.keys():
		draw_rect(
			Rect2(tilemap.map_to_local(pos), Vector2.ZERO).grow(8),
			Color.RED,
			false,
			2.0,
		)

func _get_selection() -> Array[Vector2i]:
	var arr: Array[Vector2i] = []
	for p in selected.keys():
		arr.push_back(p)
	return arr

func add_cell_at_mouse() -> void:
	add_cell(tilemap.local_to_map(tilemap.get_local_mouse_position()))

func _enter_tree() -> void:
	add_cell_at_mouse()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		add_cell_at_mouse()
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed():
			over()
	elif  event.is_action_pressed("ui_cancel"):
		cancel()
