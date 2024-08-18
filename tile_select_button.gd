extends Button

class_name TileSelectButton

@export
var meta_name: String

@export
var minus_meta: Array[String] = []

func get_domain(patcher: WFC2DPatcher) -> WFCBitSet:
	var domain := patcher.get_domain_by_meta(meta_name, true)

	for mm in minus_meta:
		domain.intersect_in_place(
			patcher.get_domain_by_meta(mm, true).invert()
		)

	return domain
