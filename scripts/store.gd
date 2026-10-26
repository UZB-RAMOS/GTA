extends Area3D

@export var dokon_nomi := "Mahalla do‘koni"
@export var dokon_rangi := Color("267f68")
@export var dokon_turi := "umumiy"
var mahsulotlar: Array[Dictionary] = []

func _ready() -> void:
	name = "InteraktivDokon"
	add_to_group("dokon")
	collision_layer = 0
	collision_mask = 2
	monitoring = true
	_mahsulotlarni_sozla()
	_yarat_bino()

func _mahsulotlarni_sozla() -> void:
	match dokon_turi:
		"oziq_ovqat":
			mahsulotlar = [
				{"id": "osh", "nom": "Issiq osh", "belgi": "OVQAT", "narx": 3500, "izoh": "+25 jon", "tur": "sarflanadigan", "miqdor": 1},
				{"id": "dori", "nom": "Birinchi yordam qutisi", "belgi": "DORI", "narx": 5000, "izoh": "+40 jon", "tur": "sarflanadigan", "miqdor": 1}
			]
		"kiyim":
			mahsulotlar = [
				{"id": "kiyim_tungi", "nom": "Tungi shahar kiyimi", "belgi": "KIYIM", "narx": 18000, "izoh": "Inventar buyumi", "tur": "kiyim", "miqdor": 1},
				{"id": "zirh", "nom": "Himoya nimchasi", "belgi": "ZIRH", "narx": 22000, "izoh": "+60 zirh", "tur": "himoya", "miqdor": 1}
			]
		"avtosalon":
			mahsulotlar = [
				{"id": "hatchback", "nom": "JMJ ixcham hatchback", "belgi": "AVTO", "narx": 90000, "izoh": "Egalikdagi transport", "tur": "transport", "miqdor": 1},
				{"id": "suv", "nom": "JMJ shahar SUV", "belgi": "AVTO", "narx": 145000, "izoh": "Egalikdagi transport", "tur": "transport", "miqdor": 1},
				{"id": "sport", "nom": "JMJ tungi sportcar", "belgi": "AVTO", "narx": 220000, "izoh": "Egalikdagi transport", "tur": "transport", "miqdor": 1}
			]
		"servis":
			mahsulotlar = [
				{"id": "tamir", "nom": "To‘liq texnik xizmat", "belgi": "SERVIS", "narx": 12000, "izoh": "Yaqin transportni tiklaydi", "tur": "xizmat", "miqdor": 1},
				{"id": "tezlik_sozlash", "nom": "Arcade boshqaruv sozlamasi", "belgi": "SERVIS", "narx": 18000, "izoh": "Egalikdagi mashina tezlanishi +8%", "tur": "xizmat", "miqdor": 1}
			]
		_:
			mahsulotlar = [
				{"id": "tayoq", "nom": "Metall tayoq", "belgi": "ANJOM", "narx": 12000, "izoh": "38 zarar", "tur": "anjom", "miqdor": 1},
				{"id": "elektroshoker", "nom": "Elektroshoker", "belgi": "ANJOM", "narx": 35000, "izoh": "55 zarar", "tur": "anjom", "miqdor": 1},
				{"id": "fonar", "nom": "Cho‘ntak fonari", "belgi": "AKSESSUAR", "narx": 8000, "izoh": "Inventar buyumi", "tur": "aksessuar", "miqdor": 1}
			]

func ochish(_oyinchi: Node3D) -> void:
	get_tree().call_group("oyin_tizimi", "dokon_och", self)

func _yarat_bino() -> void:
	var devor_mat := _material(dokon_rangi, 0.82)
	var tom_mat := _material(dokon_rangi.darkened(0.25), 0.72)
	var oyna_mat := _material(Color(0.08, 0.23, 0.29, 0.76), 0.20)
	oyna_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	var metall := _material(Color("4a5358"), 0.45)

	var statik := StaticBody3D.new()
	statik.name = "DokonBinolari"
	statik.collision_layer = 1
	statik.collision_mask = 0
	add_child(statik)
	var collider := CollisionShape3D.new()
	var shakl := BoxShape3D.new()
	shakl.size = Vector3(9.5, 3.5, 6.5)
	collider.shape = shakl
	collider.position.y = 1.75
	statik.add_child(collider)
	_quti(statik, Vector3(0, 1.75, 0), Vector3(9.5, 3.5, 6.5), devor_mat)
	_quti(statik, Vector3(0, 3.72, 0), Vector3(10.2, 0.38, 7.2), tom_mat)
	_quti(statik, Vector3(0, 1.45, -3.29), Vector3(2.0, 2.9, 0.10), _material(Color("5d3d29"), 0.75))
	for x in [-3.1, 3.1]:
		_quti(statik, Vector3(x, 1.65, -3.30), Vector3(2.15, 1.85, 0.10), oyna_mat)
		_quti(statik, Vector3(x, 2.68, -3.55), Vector3(2.45, 0.12, 0.58), tom_mat)
	for x in [-4.25, 4.25]:
		_quti(statik, Vector3(x, 2.0, -3.45), Vector3(0.09, 3.5, 0.09), metall)

	var yozuv := Label3D.new()
	yozuv.text = dokon_nomi.to_upper()
	yozuv.font_size = 38
	yozuv.outline_size = 8
	yozuv.position = Vector3(0, 4.32, -3.15)
	yozuv.modulate = Color("fff1ba")
	add_child(yozuv)
	var yordam := Label3D.new()
	yordam.text = "E — DO‘KONNI OCHISH"
	yordam.font_size = 22
	yordam.outline_size = 5
	yordam.position = Vector3(0, 2.85, -3.55)
	yordam.modulate = Color("8ff0b0")
	add_child(yordam)

	var area_collider := CollisionShape3D.new()
	var area_shakl := BoxShape3D.new()
	area_shakl.size = Vector3(5.2, 2.4, 3.4)
	area_collider.shape = area_shakl
	area_collider.position = Vector3(0, 1.2, -4.35)
	add_child(area_collider)

func _quti(parent: Node3D, p: Vector3, hajm: Vector3, mat: Material) -> MeshInstance3D:
	var n := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = hajm
	n.mesh = mesh
	n.position = p
	n.material_override = mat
	n.visibility_range_end = 138.0
	parent.add_child(n)
	return n

func _material(rang: Color, roughness: float) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = rang
	mat.roughness = roughness
	return mat
