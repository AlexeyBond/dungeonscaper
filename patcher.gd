extends Node

class_name WFC2DPatcher

@export
var rules: WFCRules2D

@export_node_path("WFC2DLayeredMap")
var map: NodePath

@export
var solver_settings: WFCSolverSettings = WFCSolverSettings.new()

# [Vector2i] -> [WFCBitSet]
var updates: Dictionary = {}

var runner: WFCMultithreadedSolverRunner = null

func get_domain_by_meta(
	meta_name: String,
	meta_value: Variant,
	maybe_empty: bool = false,
) -> WFCBitSet:
	assert(self.rules)
	assert(self.rules.mapper.is_ready())
	assert(self.rules.is_ready())

	var mapper := self.rules.mapper;
	var domain := WFCBitSet.new(mapper.size())

	for i in range(mapper.size()):
		if meta_value in mapper.read_tile_meta(i, meta_name):
			domain.set_bit(i)

	assert(maybe_empty or not domain.is_empty())

	return domain

func update_cell(coords: Vector2i, domain: WFCBitSet):
	updates[coords] = domain

func try_start():
	if updates.is_empty():
		return

	if runner != null:
		return

	runner = WFCMultithreadedSolverRunner.new()
	runner.runner_settings.max_threads = 1
	runner.solver_settings = solver_settings
	runner.partial_solution.connect(_on_partial_solution)
	runner.sub_problem_solved.connect(_on_problem_solved)
	runner.all_solved.connect(_on_all_solved)
	runner.start(WFC2DPatchProblem.new(get_node(map), rules, updates))
	
	updates = {}

func cancel():
	if runner != null:
		runner.interrupt()
		runner = null
		cancelled.emit()

signal solved
signal cancelled

func _on_partial_solution(problem: WFC2DPatchProblem, state: WFCSolverState):
	#problem.render_state_to_map(state)
	pass

func _on_problem_solved(problem: WFC2DPatchProblem, state: WFCSolverState):
	if state != null:
		problem.render_state_to_map(state)

func _on_all_solved():
	runner = null
	solved.emit()

func is_busy() -> bool:
	return runner != null

func _process(_delta: float) -> void:
	if runner != null:
		runner.update()
