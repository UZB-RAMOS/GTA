extends RefCounted

const DUNYO_QATLAMI := 1
const TOQNASHUV_QATLAMLARI := 1 | 4 | 8
const ENG_KAM_YER_NORMALI := 0.72

static func xavfsiz_nuqta_topish(
	transport: CharacterBody3D,
	haydovchi: CharacterBody3D,
	yon_masofa: float,
	old_masofa: float
) -> Dictionary:
	if not is_instance_valid(transport) or not is_instance_valid(haydovchi) or not transport.is_inside_tree():
		return {}
	var yon := transport.global_transform.basis.x.normalized()
	var old := -transport.global_transform.basis.z.normalized()
	var nomzodlar := [
		transport.global_position - yon * yon_masofa,
		transport.global_position + yon * yon_masofa,
		transport.global_position - old * old_masofa,
		transport.global_position + old * old_masofa
	]
	var fazo := transport.get_world_3d().direct_space_state
	var shakl := CapsuleShape3D.new()
	shakl.radius = 0.42
	shakl.height = 1.80
	for nomzod in nomzodlar:
		var yer_sorovi := PhysicsRayQueryParameters3D.create(
			nomzod + Vector3.UP * 2.4,
			nomzod + Vector3.DOWN * 3.0,
			DUNYO_QATLAMI,
			[transport.get_rid(), haydovchi.get_rid()]
		)
		var yer := fazo.intersect_ray(yer_sorovi)
		if yer.is_empty():
			continue
		var normal: Vector3 = yer.get("normal", Vector3.UP)
		if normal.dot(Vector3.UP) < ENG_KAM_YER_NORMALI:
			continue
		var joy: Vector3 = yer.position + Vector3.UP * 0.03
		var tana_sorovi := PhysicsShapeQueryParameters3D.new()
		tana_sorovi.shape = shakl
		tana_sorovi.transform = Transform3D(Basis.IDENTITY, joy + Vector3.UP * 0.92)
		tana_sorovi.collision_mask = TOQNASHUV_QATLAMLARI
		tana_sorovi.exclude = [transport.get_rid(), haydovchi.get_rid()]
		if fazo.intersect_shape(tana_sorovi, 1).is_empty():
			return {"joy": joy, "yer_normali": normal}
	return {}
