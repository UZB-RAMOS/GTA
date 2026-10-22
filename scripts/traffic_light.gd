extends Node3D

@export var vertikal_yol := true
@export var faza_siljishi := 0.0
var qizil_lampa: MeshInstance3D
var sariq_lampa: MeshInstance3D
var yashil_lampa: MeshInstance3D
var yangilash_vaqti := 0.0
var oxirgi_holat := -1

func _ready() -> void:
	add_to_group("svetofor")
	_yarat_model()
	yangilash_vaqti = float(get_instance_id() % 10) * 0.025

func _process(delta: float) -> void:
	yangilash_vaqti -= delta
	if yangilash_vaqti > 0.0:
		return
	yangilash_vaqti = 0.25
	var holat := _joriy_holat(vertikal_yol)
	if holat == oxirgi_holat:
		return
	oxirgi_holat = holat
	_lampa_yon(qizil_lampa, holat == 0, Color("e52f32"))
	_lampa_yon(sariq_lampa, holat == 1, Color("f1bd2b"))
	_lampa_yon(yashil_lampa, holat == 2, Color("31c96b"))

func qizilmi(harakat_vertikal: bool) -> bool:
	return _joriy_holat(harakat_vertikal) != 2

func _joriy_holat(harakat_vertikal: bool) -> int:
	var sekund := fmod(Time.get_ticks_msec() / 1000.0 + faza_siljishi, 16.0)
	if harakat_vertikal:
		if sekund < 6.0:
			return 2
		if sekund < 7.0:
			return 1
		return 0
	else:
		if sekund >= 8.0 and sekund < 14.0:
			return 2
		if sekund >= 14.0 and sekund < 15.0:
			return 1
		return 0

func _yarat_model() -> void:
	var metall := _material(Color("343b3d"), 0.56, 0.75)
	var qora := _material(Color("101519"), 0.82)
	_silindr(Vector3(0, 1.75, 0), 0.08, 3.5, metall)
	_quti(Vector3(0, 3.32, 0), Vector3(0.48, 1.30, 0.38), qora)
	_quti(Vector3(0, 3.32, -0.24), Vector3(0.62, 1.38, 0.10), metall)
	qizil_lampa = _sfera(Vector3(0, 3.72, -0.31), Color("e52f32"))
	sariq_lampa = _sfera(Vector3(0, 3.32, -0.31), Color("f1bd2b"))
	yashil_lampa = _sfera(Vector3(0, 2.92, -0.31), Color("31c96b"))
	for y in [2.92, 3.32, 3.72]:
		var soyabon := _quti(Vector3(0, y + 0.13, -0.43), Vector3(0.45, 0.08, 0.32), qora)
		soyabon.rotation.x = deg_to_rad(-12.0)

func _lampa_yon(lampa: MeshInstance3D, yoniq: bool, rang: Color) -> void:
	var mat := lampa.material_override as StandardMaterial3D
	mat.albedo_color = rang if yoniq else rang.darkened(0.72)
	mat.emission_enabled = yoniq
	mat.emission = rang
	mat.emission_energy_multiplier = 2.8 if yoniq else 0.0

func _material(rang: Color, roughness := 0.8, metallic := 0.0) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = rang
	mat.roughness = roughness
	mat.metallic = metallic
	return mat

func _quti(p: Vector3, hajm: Vector3, mat: Material) -> MeshInstance3D:
	var n := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = hajm
	n.mesh = mesh
	n.position = p
	n.material_override = mat
	n.visibility_range_end = 58.0
	add_child(n)
	return n

func _silindr(p: Vector3, radius: float, balandlik: float, mat: Material) -> MeshInstance3D:
	var n := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = balandlik
	mesh.radial_segments = 12
	mesh.rings = 1
	n.mesh = mesh
	n.position = p
	n.material_override = mat
	n.visibility_range_end = 58.0
	add_child(n)
	return n

func _sfera(p: Vector3, rang: Color) -> MeshInstance3D:
	var n := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 0.16
	mesh.height = 0.32
	mesh.radial_segments = 10
	mesh.rings = 5
	n.mesh = mesh
	n.position = p
	n.scale.z = 0.48
	n.material_override = _material(rang.darkened(0.7), 0.3)
	n.visibility_range_end = 58.0
	add_child(n)
	return n
