extends Node3D

signal hudud_tayyor

const TrafficLightScript = preload("res://scripts/traffic_light.gd")
const CHUNK_HAJMI := 70.0
const HUDUD_MIN_X := 105.0
const HUDUD_MAX_X := 174.0
const HUDUD_MARKAZ_X := 139.5
const YOL_Z := [-70.0, -35.0, 0.0, 35.0, 70.0]
const YOL_YARIM_KENGLIGI := 5.75

var tayyor := false
var qurilgan_chunklar := 0
var materiallar: Dictionary = {}

func _ready() -> void:
	name = "Phase8SharqiyXiyobon"
	add_to_group("phase8_hudud")
	_materiallarni_tayyorla()
	_qurilishni_boshlash.call_deferred()

func _materiallarni_tayyorla() -> void:
	materiallar = {
		"yer": _material(Color("26392c"), 0.92),
		"asfalt": _material(Color("aab4bf"), 0.82),
		"trotuar": _material(Color("565b61"), 0.78),
		"beton": _material(Color("ada79c"), 0.72),
		"g_sht": _material(Color("765449"), 0.88),
		"shisha": _pbr_material(Color("173e52"), 0.20, 0.38),
		"metall": _pbr_material(Color("4b555c"), 0.40, 0.58),
		"oyna": _emissive_material(Color("ffe09a"), 1.42),
		"neon": _emissive_material(Color("55d8ef"), 1.72),
		"pushti_neon": _emissive_material(Color("ef66c9"), 1.62),
		"daraxt": _material(Color("3e7448"), 0.94),
		"yogoch": _material(Color("76513a"), 0.90),
		"chiziq": _material(Color("c4a744"), 0.66)
	}

func _qurilishni_boshlash() -> void:
	# SceneTree xavfsizligi uchun har bir yangi chunk main threadda alohida kadrda tayyorlanadi.
	for z_markaz in [-70.0, 0.0, 70.0]:
		var chunk := _chunk_yarat(z_markaz)
		_chunk_asosini_yarat(chunk, z_markaz)
		_chunk_arxitekturasini_yarat(chunk, z_markaz)
		qurilgan_chunklar += 1
		await get_tree().process_frame
	_svetoforlarni_yarat()
	_korsatkich_yarat(self, Vector3(139.5, 8.4, -2.0), "SHARQIY XIYOBON", Color("2b8ca5"))
	tayyor = true
	hudud_tayyor.emit()

func _chunk_yarat(z_markaz: float) -> Node3D:
	var chunk := Node3D.new()
	chunk.name = "Chunk_2_%d" % int(round(z_markaz / CHUNK_HAJMI))
	chunk.set_meta("hajm", Vector2(CHUNK_HAJMI, CHUNK_HAJMI))
	chunk.set_meta("markaz", Vector2(140.0, z_markaz))
	chunk.set_meta("faol", true)
	chunk.set_meta("phase8", true)
	chunk.add_to_group("dunyo_chunki")
	chunk.add_to_group("phase8_chunk")
	add_child(chunk)
	return chunk

func _chunk_asosini_yarat(chunk: Node3D, z_markaz: float) -> void:
	_statik_quti(chunk, "SharqiyYer", Vector3(HUDUD_MARKAZ_X, -0.3, z_markaz), Vector3(69.0, 0.6, 70.0), materiallar.yer)
	# Sharqiy vertikal xiyobon barcha uch chunk orqali o‘tadi.
	_mesh_quti(chunk, Vector3(140.0, 0.03, z_markaz), Vector3(11.5, 0.06, 69.5), materiallar.asfalt, 132.0, "asfalt")
	for taraf in [-6.8, 6.8]:
		_mesh_quti(chunk, Vector3(140.0 + taraf, 0.105, z_markaz), Vector3(1.8, 0.21, 69.5), materiallar.trotuar, 124.0)
	# Eski shahar yo‘llari uzilmasdan yangi hududgacha davom etadi.
	for z_yol in YOL_Z:
		if _yol_chunk_markazi(z_yol) != z_markaz:
			continue
		_mesh_quti(chunk, Vector3(HUDUD_MARKAZ_X, 0.035, z_yol), Vector3(69.0, 0.06, 11.5), materiallar.asfalt, 132.0, "asfalt")
		for taraf in [-6.8, 6.8]:
			_mesh_quti(chunk, Vector3(HUDUD_MARKAZ_X, 0.11, z_yol + taraf), Vector3(69.0, 0.21, 1.8), materiallar.trotuar, 124.0)
	_yol_chiziqlari(chunk, z_markaz)
	_kocha_detallari(chunk, z_markaz)

func _yol_chiziqlari(chunk: Node3D, z_markaz: float) -> void:
	var vertikal: Array[Vector3] = []
	for i in range(-6, 8):
		var z := z_markaz + float(i) * 5.0
		if z >= z_markaz - 34.0 and z <= z_markaz + 34.0:
			vertikal.append(Vector3(140.0, 0.078, z))
	_multimesh_quti(chunk, "SharqiyVertikalChiziq", Vector3(0.13, 0.025, 2.6), vertikal, materiallar.chiziq, 124.0)
	var gorizontal: Array[Vector3] = []
	for z_yol in YOL_Z:
		if _yol_chunk_markazi(z_yol) != z_markaz:
			continue
		for i in range(8):
			gorizontal.append(Vector3(108.0 + float(i) * 8.2, 0.08, z_yol))
	_multimesh_quti(chunk, "SharqiyGorizontalChiziq", Vector3(3.8, 0.025, 0.13), gorizontal, materiallar.chiziq, 124.0)

func _yol_chunk_markazi(z: float) -> float:
	if z <= -35.0:
		return -70.0
	if z <= 35.0:
		return 0.0
	return 70.0

func _chunk_arxitekturasini_yarat(chunk: Node3D, z_markaz: float) -> void:
	match int(z_markaz):
		-70:
			_bino_yarat(chunk, "SharqMehmonxonasi", Vector3(122.5, 8.5, -52.5), Vector3(14.0, 17.0, 11.0), materiallar.beton, "SHARQ MEHMONXONASI", true)
			_bino_yarat(chunk, "TexnologiyaMinorasi", Vector3(157.5, 11.0, -87.0), Vector3(12.0, 22.0, 12.0), materiallar.shisha, "TEXNOLOGIYA MARKAZI", true)
		0:
			_bino_yarat(chunk, "BiznesMarkazi", Vector3(122.5, 9.0, -17.5), Vector3(13.0, 18.0, 12.0), materiallar.shisha, "YANGI BIZNES MARKAZ", true)
			_bino_yarat(chunk, "SharqSavdoUyi", Vector3(157.5, 5.0, 17.5), Vector3(15.0, 10.0, 13.0), materiallar.g_sht, "SHARQ SAVDO UYI", false)
			_osma_koprik_yarat(chunk)
		70:
			_xiyobon_yarat(chunk, Vector3(122.5, 0.0, 52.5))
			_bino_yarat(chunk, "TransportMarkazi", Vector3(157.5, 5.8, 87.0), Vector3(15.0, 11.6, 12.0), materiallar.metall, "TRANSPORT MARKAZI", true)

func _bino_yarat(chunk: Node3D, nom: String, p: Vector3, hajm: Vector3, material: Material, yozuv: String, landmark: bool) -> void:
	var bino := _statik_quti(chunk, nom, p, hajm, material)
	bino.add_to_group("phase8_obyekt")
	if landmark:
		bino.add_to_group("landmark")
		bino.add_to_group("phase8_landmark")
	# Eshik, soyabon, tom bloki va ikki rangli fasad bino siluetini boyitadi.
	_mesh_quti(bino, Vector3(0, -hajm.y * 0.5 + 1.25, -hajm.z * 0.5 - 0.06), Vector3(1.8, 2.5, 0.12), materiallar.metall, 88.0)
	_mesh_quti(bino, Vector3(0, -hajm.y * 0.5 + 2.8, -hajm.z * 0.5 - 0.7), Vector3(4.0, 0.20, 1.4), materiallar.neon, 92.0)
	_mesh_quti(bino, Vector3(hajm.x * 0.23, hajm.y * 0.5 + 0.65, 0), Vector3(2.5, 1.3, 2.3), materiallar.metall, 96.0)
	var oyna_joylari: Array[Vector3] = []
	var qavatlar := maxi(2, int(hajm.y / 2.8))
	for qavat in range(qavatlar):
		var y := -hajm.y * 0.5 + 1.7 + float(qavat) * 2.55
		for x in [-hajm.x * 0.31, 0.0, hajm.x * 0.31]:
			oyna_joylari.append(Vector3(x, y, -hajm.z * 0.5 - 0.07))
	_multimesh_quti(bino, "YoniqDerazalar", Vector3(1.45, 1.12, 0.08), oyna_joylari, materiallar.oyna, 82.0)
	_korsatkich_yarat(bino, Vector3(0, hajm.y * 0.5 + 1.6, -hajm.z * 0.5), yozuv, Color("22697c"))

func _osma_koprik_yarat(chunk: Node3D) -> void:
	var koprik := Node3D.new()
	koprik.name = "SharqiyPiyodaKoprigi"
	koprik.add_to_group("phase8_obyekt")
	chunk.add_child(koprik)
	for x in [134.0, 146.0]:
		_statik_quti(koprik, "KoprikTayanchi", Vector3(x, 3.1, 35.0), Vector3(1.1, 6.2, 1.1), materiallar.beton)
	_statik_quti(koprik, "KoprikYolagi", Vector3(140.0, 6.2, 35.0), Vector3(14.0, 0.55, 2.8), materiallar.metall)
	_mesh_quti(koprik, Vector3(140.0, 7.0, 33.7), Vector3(13.0, 0.14, 0.14), materiallar.neon, 115.0)
	_mesh_quti(koprik, Vector3(140.0, 7.0, 36.3), Vector3(13.0, 0.14, 0.14), materiallar.pushti_neon, 115.0)

func _xiyobon_yarat(chunk: Node3D, markaz: Vector3) -> void:
	var xiyobon := _statik_quti(chunk, "SharqiyXiyobonMaydoni", markaz + Vector3(0, 0.14, 0), Vector3(20.0, 0.28, 19.0), materiallar.trotuar)
	xiyobon.add_to_group("phase8_obyekt")
	xiyobon.add_to_group("landmark")
	xiyobon.add_to_group("phase8_landmark")
	for x in [-7.0, 7.0]:
		_mesh_quti(xiyobon, Vector3(x, 3.0, 0), Vector3(0.8, 6.0, 0.8), materiallar.beton, 110.0)
	_mesh_quti(xiyobon, Vector3(0, 5.9, 0), Vector3(15.0, 0.7, 1.0), materiallar.neon, 110.0)
	var daraxt_joylari: Array[Vector3] = []
	for x in [-7.0, -3.5, 3.5, 7.0]:
		for z in [-6.0, 6.0]:
			daraxt_joylari.append(Vector3(x, 1.65, z))
	_multimesh_sfera(xiyobon, "XiyobonDaraxtlari", Vector3(1.5, 2.4, 1.5), daraxt_joylari, materiallar.daraxt, 95.0)
	_korsatkich_yarat(xiyobon, Vector3(0, 7.2, 0), "YANGI TOSHKENT XIYOBONI", Color("31899b"))

func _kocha_detallari(chunk: Node3D, z_markaz: float) -> void:
	var ustunlar: Array[Vector3] = []
	for z in [z_markaz - 24.0, z_markaz + 24.0]:
		for x in [132.8, 147.2]:
			ustunlar.append(Vector3(x, 2.6, z))
	_multimesh_quti(chunk, "SharqiyChiroqUstunlari", Vector3(0.13, 5.2, 0.13), ustunlar, materiallar.metall, 105.0)
	for i in range(2):
		var chiroq := OmniLight3D.new()
		chiroq.name = "SharqiyKochaYorugligi"
		chiroq.position = Vector3(132.8 if i == 0 else 147.2, 4.9, z_markaz - 24.0 if i == 0 else z_markaz + 24.0)
		chiroq.light_color = Color("ffd99a")
		chiroq.light_energy = 2.45
		chiroq.omni_range = 14.0
		chiroq.omni_attenuation = 1.4
		chiroq.shadow_enabled = false
		chiroq.distance_fade_enabled = true
		chiroq.distance_fade_begin = 28.0
		chiroq.distance_fade_length = 13.0
		chiroq.add_to_group("shahar_chirogi")
		chunk.add_child(chiroq)
	var orindiqlar: Array[Vector3] = []
	for x in [116.0, 163.0]:
		orindiqlar.append(Vector3(x, 0.48, z_markaz + 12.0))
	_multimesh_quti(chunk, "SharqiyOrindiqlar", Vector3(2.0, 0.22, 0.55), orindiqlar, materiallar.yogoch, 86.0)

func _svetoforlarni_yarat() -> void:
	for z in YOL_Z:
		var chunk := _z_uchun_chunk(z)
		if not is_instance_valid(chunk):
			continue
		var sozlamalar := [
			[Vector3(133.3, 0, z - 6.7), 0.0, true],
			[Vector3(146.7, 0, z + 6.7), PI, true],
			[Vector3(146.7, 0, z - 6.7), -PI / 2.0, false],
			[Vector3(133.3, 0, z + 6.7), PI / 2.0, false]
		]
		for sozlama in sozlamalar:
			var svetofor := TrafficLightScript.new()
			svetofor.name = "SharqiySvetofor"
			svetofor.position = sozlama[0]
			svetofor.rotation.y = sozlama[1]
			svetofor.vertikal_yol = sozlama[2]
			chunk.add_child(svetofor)

func _z_uchun_chunk(z: float) -> Node3D:
	var eng_yaqin: Node3D
	var eng_masofa := INF
	for child in get_children():
		if child.is_in_group("phase8_chunk"):
			var markaz: Vector2 = child.get_meta("markaz", Vector2.ZERO)
			var masofa := absf(markaz.y - z)
			if masofa < eng_masofa:
				eng_masofa = masofa
				eng_yaqin = child
	return eng_yaqin

func holat_ol() -> Dictionary:
	return {
		"tayyor": tayyor,
		"chunklar": qurilgan_chunklar,
		"min_x": HUDUD_MIN_X,
		"max_x": HUDUD_MAX_X,
		"nom": "Sharqiy xiyobon"
	}

func _statik_quti(parent: Node3D, nom: String, p: Vector3, hajm: Vector3, mat: Material) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = nom
	body.position = p
	body.collision_layer = 1
	body.collision_mask = 0
	parent.add_child(body)
	var collider := CollisionShape3D.new()
	var shakl := BoxShape3D.new()
	shakl.size = hajm
	collider.shape = shakl
	body.add_child(collider)
	_mesh_quti(body, Vector3.ZERO, hajm, mat, 132.0)
	return body

func _mesh_quti(parent: Node3D, p: Vector3, hajm: Vector3, mat: Material, masofa: float, guruh := "") -> MeshInstance3D:
	var n := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = hajm
	n.mesh = mesh
	n.position = p
	n.material_override = mat
	n.visibility_range_end = masofa
	if not guruh.is_empty():
		n.add_to_group(guruh)
	parent.add_child(n)
	return n

func _multimesh_quti(parent: Node3D, nom: String, hajm: Vector3, joylar: Array[Vector3], mat: Material, masofa: float) -> MultiMeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = hajm
	mesh.material = mat
	return _multimesh(parent, nom, mesh, joylar, Vector3.ONE, masofa)

func _multimesh_sfera(parent: Node3D, nom: String, masshtab: Vector3, joylar: Array[Vector3], mat: Material, masofa: float) -> MultiMeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = 0.5
	mesh.height = 1.0
	mesh.radial_segments = 10
	mesh.rings = 6
	mesh.material = mat
	return _multimesh(parent, nom, mesh, joylar, masshtab, masofa)

func _multimesh(parent: Node3D, nom: String, mesh: Mesh, joylar: Array[Vector3], masshtab: Vector3, masofa: float) -> MultiMeshInstance3D:
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = mesh
	mm.instance_count = joylar.size()
	for i in range(joylar.size()):
		mm.set_instance_transform(i, Transform3D(Basis().scaled(masshtab), joylar[i]))
	var n := MultiMeshInstance3D.new()
	n.name = nom
	n.multimesh = mm
	n.visibility_range_end = masofa
	parent.add_child(n)
	return n

func _korsatkich_yarat(parent: Node3D, p: Vector3, matn: String, rang: Color) -> void:
	var label := Label3D.new()
	label.text = matn
	label.font_size = 36
	label.outline_size = 7
	label.modulate = Color.WHITE
	label.outline_modulate = rang.darkened(0.46)
	label.position = p
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.visibility_range_end = 105.0
	parent.add_child(label)

func _material(rang: Color, roughness: float) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = rang
	mat.roughness = roughness
	return mat

func _pbr_material(rang: Color, roughness: float, metallic: float) -> StandardMaterial3D:
	var mat := _material(rang, roughness)
	mat.metallic = metallic
	return mat

func _emissive_material(rang: Color, kuch: float) -> StandardMaterial3D:
	var mat := _material(rang, 0.24)
	mat.emission_enabled = true
	mat.emission = rang
	mat.emission_energy_multiplier = kuch
	return mat
