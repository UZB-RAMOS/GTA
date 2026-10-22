extends CharacterBody3D

@export var rang := Color("c54245")
@export var tezlik := 7.0
var yol: Array[Vector3] = []
var indeks := 0
var joriy_tezlik := 0.0
var gildiraklar: Array[MeshInstance3D] = []

func _ready() -> void:
	add_to_group("trafik")
	collision_layer = 4
	collision_mask = 1 | 4
	_yarat_model()

func _yarat_model() -> void:
	var collider := CollisionShape3D.new()
	var shakl := BoxShape3D.new()
	shakl.size = Vector3(1.74, 1.18, 3.45)
	collider.shape = shakl
	collider.position.y = 0.72
	add_child(collider)
	var kuzov := _material(rang, 0.50, 0.55)
	var qora := _material(Color("111519"), 0.75)
	var metall := _material(Color("aab0b4"), 0.25, 0.82)
	var oyna := _oyna_material()

	_quti("Shassi", Vector3(0, 0.50, 0), Vector3(1.72, 0.48, 3.38), kuzov)
	_quti("Kaput", Vector3(0, 0.83, -1.22), Vector3(1.67, 0.28, 0.95), kuzov)
	_quti("Bagaj", Vector3(0, 0.84, 1.28), Vector3(1.67, 0.30, 0.72), kuzov)
	_quti("Kabina", Vector3(0, 1.18, 0.08), Vector3(1.49, 0.70, 1.55), kuzov)
	_quti("OldOyna", Vector3(0, 1.28, -0.73), Vector3(1.32, 0.48, 0.045), oyna)
	_quti("OrqaOyna", Vector3(0, 1.28, 0.85), Vector3(1.31, 0.46, 0.045), oyna)
	for x in [-0.765, 0.765]:
		_quti("YonOyna", Vector3(x, 1.29, 0.08), Vector3(0.045, 0.44, 1.18), oyna)
		_quti("Kozgu", Vector3(x * 1.11, 1.23, -0.67), Vector3(0.20, 0.16, 0.24), kuzov)
	for x in [-0.55, 0.55]:
		_quti("Fara", Vector3(x, 0.78, -1.72), Vector3(0.35, 0.20, 0.05), _emissive(Color("fff1ba"), 1.8))
		_quti("Stop", Vector3(x, 0.79, 1.72), Vector3(0.34, 0.21, 0.05), _emissive(Color("cf3030"), 1.2))
	_quti("OldBamper", Vector3(0, 0.42, -1.75), Vector3(1.82, 0.18, 0.13), qora)
	_quti("OrqaBamper", Vector3(0, 0.42, 1.75), Vector3(1.82, 0.18, 0.13), qora)
	_quti("Raqam", Vector3(0, 0.60, -1.79), Vector3(0.54, 0.16, 0.025), _material(Color("f5f3e9")))
	for x in [-0.88, 0.88]:
		for z in [-1.13, 1.12]:
			var shina := _silindr(Vector3(x, 0.45, z), 0.34, 0.25, qora)
			shina.rotation.z = PI / 2.0
			var disk := _silindr(Vector3(x * 1.01, 0.45, z), 0.16, 0.27, metall)
			disk.rotation.z = PI / 2.0
			gildiraklar.append(shina)

	# Salon ichida ko‘rinadigan haydovchi silueti.
	_quti("HaydovchiGavda", Vector3(-0.38, 1.12, -0.05), Vector3(0.38, 0.45, 0.27), _material(Color("3c596f")))
	_sfera("HaydovchiBosh", Vector3(-0.38, 1.52, -0.08), Vector3(0.32, 0.38, 0.32), _material(Color("c99168")))

func _physics_process(delta: float) -> void:
	if yol.is_empty():
		return
	var maqsad := yol[indeks]
	var farq := maqsad - global_position
	farq.y = 0.0
	if farq.length() < 2.0:
		indeks = (indeks + 1) % yol.size()
		return
	var yonalish := farq.normalized()
	var kerak_burilish := atan2(-yonalish.x, -yonalish.z)
	rotation.y = lerp_angle(rotation.y, kerak_burilish, delta * 2.3)
	var maqsad_tezlik := 0.0 if _qizil_chiroq_yaqin() or _oldinda_mashina() else tezlik
	joriy_tezlik = move_toward(joriy_tezlik, maqsad_tezlik, (10.0 if maqsad_tezlik == 0.0 else 3.0) * delta)
	velocity = -global_transform.basis.z * joriy_tezlik
	velocity.y = -0.5
	move_and_slide()
	for gildirak in gildiraklar:
		gildirak.rotate_x(joriy_tezlik * delta / 0.34)

func _qizil_chiroq_yaqin() -> bool:
	var vertikal: bool = abs(global_transform.basis.z.z) > abs(global_transform.basis.z.x)
	for chiroq in get_tree().get_nodes_in_group("svetofor"):
		if not chiroq.has_method("qizilmi"):
			continue
		var lokal := to_local(chiroq.global_position)
		if lokal.z < -0.5 and lokal.z > -7.5 and abs(lokal.x) < 4.0 and chiroq.qizilmi(vertikal):
			return true
	return false

func _oldinda_mashina() -> bool:
	for boshqa in get_tree().get_nodes_in_group("trafik"):
		if boshqa == self:
			continue
		var lokal := to_local(boshqa.global_position)
		if lokal.z < -0.2 and lokal.z > -4.6 and abs(lokal.x) < 1.25:
			return true
	return false

func _material(r: Color, roughness := 0.72, metallic := 0.0) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = r
	mat.roughness = roughness
	mat.metallic = metallic
	return mat

func _oyna_material() -> StandardMaterial3D:
	var mat := _material(Color(0.04, 0.10, 0.15, 0.82), 0.16, 0.25)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return mat

func _emissive(r: Color, kuch: float) -> StandardMaterial3D:
	var mat := _material(r, 0.2)
	mat.emission_enabled = true
	mat.emission = r
	mat.emission_energy_multiplier = kuch
	return mat

func _quti(nom: String, p: Vector3, hajm: Vector3, mat: Material) -> MeshInstance3D:
	var n := MeshInstance3D.new()
	n.name = nom
	var mesh := BoxMesh.new()
	mesh.size = hajm
	n.mesh = mesh
	n.position = p
	n.material_override = mat
	add_child(n)
	return n

func _silindr(p: Vector3, radius: float, uzunlik: float, mat: Material) -> MeshInstance3D:
	var n := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = uzunlik
	n.mesh = mesh
	n.position = p
	n.material_override = mat
	add_child(n)
	return n

func _sfera(nom: String, p: Vector3, masshtab: Vector3, mat: Material) -> MeshInstance3D:
	var n := MeshInstance3D.new()
	n.name = nom
	var mesh := SphereMesh.new()
	mesh.radius = 0.5
	mesh.height = 1.0
	n.mesh = mesh
	n.position = p
	n.scale = masshtab
	n.material_override = mat
	add_child(n)
	return n
