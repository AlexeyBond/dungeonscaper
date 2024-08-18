extends Selection

class_name RectSelection

var start_pos: Vector2i
var end_pos: Vector2i

func _add_cell(pos: Vector2i):
	end_pos = pos

func _draw() -> void:
	if _cancelled:
		return

	var r := Rect2(tilemap.map_to_local(start_pos), Vector2.ZERO)
	r = r.expand(tilemap.map_to_local(end_pos)).grow(8)

	draw_rect(
		r,
		Color.RED,
		false,
		2.0,
	)

func _get_selection() -> Array[Vector2i]:
	var arr: Array[Vector2i] = []
	
	var r := Rect2i(start_pos, Vector2i.ONE)
	r = r.merge(Rect2i(end_pos, Vector2i.ONE))

	for dx in range(r.size.x):
		for dy in range(r.size.y):
			arr.push_back(r.position + Vector2i(dx, dy))
	
	return arr

func create_mesh() -> Mesh:
	var r := Rect2(tilemap.map_to_local(start_pos), Vector2.ZERO)
	r = r.expand(tilemap.map_to_local(end_pos)).grow(8)
	var im := ImmediateMesh.new()
	im.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	im.surface_add_vertex_2d(Vector2(r.position.x, r.position.y))
	im.surface_add_vertex_2d(Vector2(r.position.x, r.end.y))
	im.surface_add_vertex_2d(Vector2(r.end.x, r.position.y))
	im.surface_add_vertex_2d(Vector2(r.end.x, r.end.y))
	im.surface_end()
	return im

func add_cell_at_mouse() -> void:
	add_cell(tilemap.local_to_map(tilemap.get_local_mouse_position()))

func _ready() -> void:
	start_pos = tilemap.local_to_map(tilemap.get_local_mouse_position())
	end_pos = start_pos

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		add_cell_at_mouse()
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed():
			over()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			cancel()
	elif  event.is_action_pressed("ui_cancel"):
		cancel()
