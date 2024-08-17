extends Node2D

class_name Selection

var tilemap: TileMapLayer

var _cancelled: bool = false

signal on_selected(cells: Array[Vector2i])

func add_cell(pos: Vector2i):
	if _cancelled:
		return

	_add_cell(pos)
	queue_redraw()

func cancel():
	if _cancelled:
		return

	_cancelled = true
	queue_redraw()

func over():
	if !_cancelled:
		on_selected.emit(_get_selection())

	queue_free()

func _add_cell(pos: Vector2i):
	assert(false)

func _get_selection() -> Array[Vector2i]:
	assert(false)
	return []
