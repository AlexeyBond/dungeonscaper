extends WFC2DProblem

class_name WFC2DPatchProblem

class PatchPrecondition extends WFC2DPrecondition:
	var map: Node
	var mapper: WFCMapper2D
	var fixed_domains: Dictionary
	var rect: Rect2i
	var any_domain: WFCBitSet

	func _init(
		map_: Node,
		mapper_: WFCMapper2D,
		fixed_domains_: Dictionary,
		rect_: Rect2i,
	):
		self.map = map_
		self.mapper = mapper_
		self.fixed_domains = fixed_domains_
		self.rect = rect_
		self.any_domain = WFCBitSet.new(mapper.size(), true)

	func read_domain(coords: Vector2i) -> WFCBitSet:
		if not rect.has_point(coords):
			var tile := mapper.read_cell(map, coords)
			if tile < 0:
				return null

			var domain := WFCBitSet.new(mapper.size())
			domain.set_bit(tile)
			return domain

		return fixed_domains.get(coords, any_domain)

var initial_state: PackedInt32Array
var is_fixed_domain: PackedInt32Array

# [param fixed_domains] - [Vector2i] -> [WFCBitSet]
func _init(map_: Node, rules_: WFCRules2D, fixed_domains: Dictionary):
	var rect_ := Rect2i()

	for pos in fixed_domains.keys():
		if rect_.has_area():
			rect_ = rect_.expand(pos)
		else:
			rect_ = Rect2i(pos, Vector2i.ONE)

	assert(rect_.has_area())

	var ir := rules_.get_influence_range()
	assert(ir.x < 100500)
	assert(ir.y < 100500)
	rect_ = rect_.grow_individual(ir.x, ir.y, ir.x, ir.y)

	var settings := WFC2DProblemSettings.new()
	settings.rules = rules_
	settings.rect = rect_.grow(1)
	super(settings, map_, PatchPrecondition.new(map_, rules_.mapper, fixed_domains, rect_))

	initial_state.resize(get_cell_count())
	is_fixed_domain.resize(get_cell_count())
	for i in range(initial_state.size()):
		initial_state[i] = rules.mapper.read_cell(map, id_to_coord(i) + rect.position)
		is_fixed_domain[i] = 1 if (rect.position + id_to_coord(i)) in fixed_domains else 0

	assert(1 in is_fixed_domain)

func pick_divergence_option_at(options: Array[int], cell: int) -> int:
	if not is_fixed_domain[cell]:
		var preferred_option := initial_state[cell]
		var preferred_option_index := options.find(preferred_option)
		if preferred_option_index >= 0:
			return options.pop_at(preferred_option_index)

	return super(options, cell)

func compute_entropy_at(domain: WFCBitSet, cell: int) -> int:
	#var e := domain.count_set_bits() - 1
	var coord := id_to_coord(cell)
	var e: int = 1 + min(coord.x, rect.size.x - coord.x) + min(coord.y, rect.size.y - coord.y)

	if is_fixed_domain[cell] > 0:
		e += domain.size

	return e
