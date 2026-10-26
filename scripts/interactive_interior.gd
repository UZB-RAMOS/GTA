extends Node3D

@export var joy_nomi := "Interaktiv bino"
@export var joy_turi := "dokon"
@export var asosiy_rang := Color("356a78")

var ichkarida := false
var eshik_pivot: Node3D
var kirish_nuqta := Vector3(0, 0.2, -2.0)
var chiqish_nuqta := Vector3(0, 0.2, 3.8)

func _ready() -> void:
	add_to_group("interyer")
	add_to_group("interaktiv_joy")
	if joy_turi == "servis":
		add_to_group("garaj")
	_yarat_interyer()

func _yarat_interyer() -> void:
	var devor := _material(asosiy_rang.darkened(0.24), 0.84)
	var pol := _material(Color("31373b"), 0.74)
	var yogoch := _material(Color("6b4a31"), 0.76)
	var yoritilgan := _emissive(Color("ffd38a"), 1.7)
	_statik_quti("Pol", Vector3(0, -0.08, 3.4), Vector3(8.4, 0.16, 8.4), pol)
	_statik_quti("OrqaDevor", Vector3(0, 2.2, 7.5), Vector3(8.4, 4.4, 0.25), devor)
	_statik_quti("ChapDevor", Vector3(-4.1, 2.2, 3.4), Vector3(0.25, 4.4, 8.4), devor)
	_statik_quti("OngDevor", Vector3(4.1, 2.2, 3.4), Vector3(0.25, 4.4, 8.4), devor)
	_statik_quti("OldChap", Vector3(-2.7, 2.2, -0.7), Vector3(3.0, 4.4, 0.25), devor)
	_statik_quti("OldOng", Vector3(2.7, 2.2, -0.7), Vector3(3.0, 4.4, 0.25), devor)
	_statik_quti("Shift", Vector3(0, 4.35, 3.4), Vector3(8.4, 0.18, 8.4), _material(asosiy_rang.darkened(0.34), 0.90))

	eshik_pivot = Node3D.new()
	eshik_pivot.name = "OchilibYopiladiganEshik"
	eshik_pivot.position = Vector3(-1.1, 0, -0.82)
	add_child(eshik_pivot)
	_vizual_quti(eshik_pivot, Vector3(1.1, 1.25, 0), Vector3(2.2, 2.5, 0.14), yogoch)

	# Uch turdagi interyer o‘zining funksional ko‘rinishiga ega.
	if joy_turi == "servis":
		for x in [-2.3, 0.0, 2.3]:
			_vizual_quti(self, Vector3(x, 0.24, 4.6), Vector3(1.6, 0.48, 3.5), _material(Color("4b5660"), 0.55))
		_vizual_quti(self, Vector3(0, 1.1, 7.1), Vector3(6.8, 1.7, 0.4), _material(Color("253039"), 0.65))
	elif joy_turi == "ofis":
		for x in [-2.3, 0.0, 2.3]:
			_vizual_quti(self, Vector3(x, 0.78, 3.8), Vector3(1.5, 0.12, 1.1), yogoch)
			_vizual_quti(self, Vector3(x, 1.32, 4.2), Vector3(0.85, 0.55, 0.06), _material(Color("162b3b"), 0.22))
	else:
		for x in [-2.8, 0.0, 2.8]:
			for z in [2.2, 4.5, 6.5]:
				_vizual_quti(self, Vector3(x, 1.25, z), Vector3(1.25, 2.5, 0.55), yogoch)

	for x in [-2.6, 0.0, 2.6]:
		_vizual_quti(self, Vector3(x, 4.12, 3.4), Vector3(1.1, 0.06, 0.42), yoritilgan)
	var chiroq := OmniLight3D.new()
	chiroq.position = Vector3(0, 3.7, 3.4)
	chiroq.light_color = Color("ffd8a0")
	chiroq.light_energy = 1.8
	chiroq.omni_range = 8.0
	chiroq.shadow_enabled = false
	chiroq.add_to_group("interyer_chirogi")
	add_child(chiroq)

	var yozuv := Label3D.new()
	yozuv.text = "%s\nE — KIRISH / CHIQISH" % joy_nomi.to_upper()
	yozuv.position = Vector3(0, 3.25, -1.0)
	yozuv.font_size = 25
	yozuv.outline_size = 6
	yozuv.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	yozuv.modulate = Color("ffe59a")
	add_child(yozuv)

func interaksiya_masofasi(oyinchi: Node3D) -> float:
	if not is_instance_valid(oyinchi):
		return INF
	var kirish := to_global(kirish_nuqta)
	var chiqish := to_global(chiqish_nuqta)
	return minf(oyinchi.global_position.distance_to(kirish), oyinchi.global_position.distance_to(chiqish))

func ishlat(oyinchi: CharacterBody3D) -> void:
	if not is_instance_valid(oyinchi) or interaksiya_masofasi(oyinchi) > 4.2:
		return
	ichkarida = not ichkarida
	var maqsad := to_global(chiqish_nuqta if ichkarida else kirish_nuqta + Vector3(0, 0, -0.8))
	oyinchi.global_position = maqsad
	oyinchi.velocity = Vector3.ZERO
	_eshikni_och()
	get_tree().call_group("audio_tizimi", "eshik_signal")
	get_tree().call_group("oyin_tizimi", "interyer_xabari", joy_nomi, ichkarida)

func _eshikni_och() -> void:
	if not is_instance_valid(eshik_pivot):
		return
	var tween := create_tween()
	tween.tween_property(eshik_pivot, "rotation:y", deg_to_rad(-92.0), 0.28).set_trans(Tween.TRANS_SINE)
	tween.tween_interval(1.0)
	tween.tween_property(eshik_pivot, "rotation:y", 0.0, 0.35).set_trans(Tween.TRANS_SINE)

func holat_ol() -> Dictionary:
	return {"name": joy_nomi, "type": joy_turi, "inside": ichkarida}

func _statik_quti(nom: String, p: Vector3, hajm: Vector3, mat: Material) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = nom
	body.collision_layer = 1
	body.collision_mask = 0
	body.position = p
	add_child(body)
	var collider := CollisionShape3D.new()
	var shakl := BoxShape3D.new()
	shakl.size = hajm
	collider.shape = shakl
	body.add_child(collider)
	_vizual_quti(body, Vector3.ZERO, hajm, mat)
	return body

func _vizual_quti(parent: Node3D, p: Vector3, hajm: Vector3, mat: Material) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = hajm
	mesh_instance.mesh = mesh
	mesh_instance.position = p
	mesh_instance.material_override = mat
	mesh_instance.visibility_range_end = 100.0
	parent.add_child(mesh_instance)
	return mesh_instance

func _material(rang: Color, roughness: float) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = rang
	mat.roughness = roughness
	return mat

func _emissive(rang: Color, kuch: float) -> StandardMaterial3D:
	var mat := _material(rang, 0.22)
	mat.emission_enabled = true
	mat.emission = rang
	mat.emission_energy_multiplier = kuch
	return mat
