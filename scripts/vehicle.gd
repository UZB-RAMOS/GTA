extends CharacterBody3D

signal haydovchi_kirdi
signal haydovchi_chiqdi
signal mustahkamlik_ozgardi(qiymat)
signal vayron_boldi

@export var maksimal_tezlik := 24.0
@export var tezlanish := 9.5
@export var tormoz := 20.0
@export var burilish_tezligi := 1.65
@export var kuzov_rangi := Color("1769aa")

var boshqarilmoqda := false
var haydovchi: CharacterBody3D
var joriy_tezlik := 0.0
var gravitatsiya := 20.0
var kuzov_root: Node3D
var eshik_pivot: Node3D
var haydovchi_modeli: Node3D
var old_gildirak_pivotlari: Array[Node3D] = []
var barcha_gildiraklar: Array[MeshInstance3D] = []
var rul_burchagi := 0.0
var maksimal_mustahkamlik := 160
var mustahkamlik := 160
var zarba_sovush_vaqti := 0.0
var vayron := false

func _ready() -> void:
	add_to_group("transport")
	collision_layer = 4
	collision_mask = 1 | 2 | 4 | 8
	_yarat_kuzov()

func _yarat_kuzov() -> void:
	var collider := CollisionShape3D.new()
	var shakl := BoxShape3D.new()
	shakl.size = Vector3(1.92, 1.55, 4.05)
	collider.shape = shakl
	collider.position.y = 0.94
	add_child(collider)

	kuzov_root = Node3D.new()
	kuzov_root.name = "BatafsilMikroavtobus"
	add_child(kuzov_root)
	var kuzov := _material(kuzov_rangi, 0.48, 0.68)
	var quyuq_kuzov := _material(kuzov_rangi.darkened(0.16), 0.55, 0.62)
	var qora := _material(Color("11161b"), 0.72)
	var metall := _material(Color("aab2b7"), 0.28, 0.82)
	var oyna := _oyna_material()

	_quti(kuzov_root, "Shassi", Vector3(0, 0.55, 0.12), Vector3(1.93, 0.55, 3.95), quyuq_kuzov)
	_quti(kuzov_root, "AsosiyKuzov", Vector3(0, 1.04, 0.38), Vector3(1.88, 0.75, 3.18), kuzov)
	_quti(kuzov_root, "OldKaput", Vector3(0, 1.02, -1.58), Vector3(1.84, 0.48, 0.92), kuzov)
	_quti(kuzov_root, "Kabina", Vector3(0, 1.61, 0.28), Vector3(1.76, 0.66, 2.32), kuzov)
	_quti(kuzov_root, "Tom", Vector3(0, 1.99, 0.30), Vector3(1.82, 0.16, 2.65), quyuq_kuzov)
	_quti(kuzov_root, "OldBamper", Vector3(0, 0.48, -2.02), Vector3(2.02, 0.22, 0.18), qora)
	_quti(kuzov_root, "OrqaBamper", Vector3(0, 0.48, 2.08), Vector3(2.02, 0.22, 0.18), qora)
	_quti(kuzov_root, "RadiatorPanjara", Vector3(0, 0.94, -2.055), Vector3(1.18, 0.36, 0.05), qora)
	for x in [-0.43, -0.22, 0.0, 0.22, 0.43]:
		_quti(kuzov_root, "Panjara", Vector3(x, 0.94, -2.087), Vector3(0.055, 0.31, 0.025), metall)

	# Old va orqa oynalar, yon oynalar.
	_quti(kuzov_root, "OldOyna", Vector3(0, 1.68, -0.915), Vector3(1.54, 0.54, 0.055), oyna)
	_quti(kuzov_root, "OrqaOyna", Vector3(0, 1.64, 1.485), Vector3(1.50, 0.52, 0.055), oyna)
	for x in [-0.905, 0.905]:
		for z in [-0.47, 0.30, 1.02]:
			_quti(kuzov_root, "YonOyna", Vector3(x, 1.67, z), Vector3(0.055, 0.48, 0.58), oyna)
		_quti(kuzov_root, "YonChiziq", Vector3(x * 1.012, 1.14, 0.45), Vector3(0.045, 0.06, 2.65), metall)

	# Fara, stop chirog‘i, raqam va kuzov choklari.
	for x in [-0.62, 0.62]:
		_quti(kuzov_root, "OldFara", Vector3(x, 0.98, -2.075), Vector3(0.42, 0.27, 0.06), _emissive(Color("fff2bd"), 2.2))
		_quti(kuzov_root, "OrqaChiroq", Vector3(x, 0.91, 2.075), Vector3(0.31, 0.42, 0.055), _emissive(Color("d52e2e"), 1.5))
	_quti(kuzov_root, "OldRaqam", Vector3(0, 0.62, -2.115), Vector3(0.62, 0.19, 0.035), _material(Color("f5f4ed"), 0.54))
	_quti(kuzov_root, "OrqaRaqam", Vector3(0, 0.66, 2.115), Vector3(0.62, 0.19, 0.035), _material(Color("f5f4ed"), 0.54))
	for x in [-1.08, 1.08]:
		_quti(kuzov_root, "KozguTayanchi", Vector3(x, 1.52, -0.78), Vector3(0.24, 0.07, 0.07), qora)
		_quti(kuzov_root, "Kozgu", Vector3(x * 1.035, 1.54, -0.78), Vector3(0.13, 0.27, 0.30), quyuq_kuzov)

	# Chap old eshik alohida pivotda ochiladi.
	eshik_pivot = Node3D.new()
	eshik_pivot.name = "HaydovchiEshigi"
	eshik_pivot.position = Vector3(-0.955, 1.18, -0.68)
	kuzov_root.add_child(eshik_pivot)
	_quti(eshik_pivot, "EshikPaneli", Vector3(-0.015, 0, 0.31), Vector3(0.07, 0.80, 0.72), kuzov)
	_quti(eshik_pivot, "Tutqich", Vector3(-0.075, 0.16, 0.48), Vector3(0.06, 0.06, 0.18), metall)

	# To‘rt g‘ildirak: shina, disk va old g‘ildirak rul pivoti.
	for x in [-1.0, 1.0]:
		for z in [-1.34, 1.35]:
			var pivot := Node3D.new()
			pivot.position = Vector3(x, 0.48, z)
			kuzov_root.add_child(pivot)
			var shina := _silindr(pivot, "Shina", Vector3.ZERO, 0.39, 0.29, qora)
			shina.rotation.z = PI / 2.0
			var disk := _silindr(pivot, "Disk", Vector3(x * 0.025, 0, 0), 0.20, 0.31, metall)
			disk.rotation.z = PI / 2.0
			barcha_gildiraklar.append(shina)
			if z < 0.0:
				old_gildirak_pivotlari.append(pivot)

	# Ichki salon, o‘rindiqlar, rul va ko‘rinadigan haydovchi.
	_quti(kuzov_root, "Panel", Vector3(0, 1.25, -0.83), Vector3(1.55, 0.18, 0.30), qora)
	_quti(kuzov_root, "ChapOrindiq", Vector3(-0.46, 1.03, -0.25), Vector3(0.55, 0.36, 0.65), _material(Color("34383b")))
	_quti(kuzov_root, "OngOrindiq", Vector3(0.46, 1.03, -0.25), Vector3(0.55, 0.36, 0.65), _material(Color("34383b")))
	var rul := _torus(kuzov_root, "Rul", Vector3(-0.47, 1.43, -0.69), 0.22, 0.035, qora)
	rul.rotation.x = deg_to_rad(68.0)
	haydovchi_modeli = _haydovchi_yarat()
	haydovchi_modeli.visible = false
	kuzov_root.add_child(haydovchi_modeli)

func _haydovchi_yarat() -> Node3D:
	var root := Node3D.new()
	root.name = "KorinadiganHaydovchi"
	root.position = Vector3(-0.46, 0.92, -0.25)
	var teri := _material(Color("c88d66"), 0.9)
	var kiyim := _material(Color("2b73bd"), 0.82)
	_quti(root, "Gavda", Vector3(0, 0.43, 0.05), Vector3(0.48, 0.62, 0.30), kiyim)
	_sfera(root, "Bosh", Vector3(0, 0.93, -0.04), Vector3(0.43, 0.50, 0.42), teri)
	for x in [-0.25, 0.25]:
		var qol := _kapsula(root, "Qol", Vector3(x, 0.42, -0.28), 0.07, 0.55, teri)
		qol.rotation.x = deg_to_rad(68.0)
	return root

func _physics_process(delta: float) -> void:
	zarba_sovush_vaqti = maxf(0.0, zarba_sovush_vaqti - delta)
	if not is_on_floor():
		velocity.y -= gravitatsiya * delta
	else:
		velocity.y = -0.25

	var gaz := 0.0
	var rul := 0.0
	if boshqarilmoqda and not vayron:
		gaz = Input.get_axis("orqaga", "oldinga")
		rul = Input.get_axis("ong", "chap")
		if gaz > 0.0:
			joriy_tezlik = move_toward(joriy_tezlik, maksimal_tezlik, tezlanish * delta)
		elif gaz < 0.0:
			if joriy_tezlik > 1.0:
				joriy_tezlik = move_toward(joriy_tezlik, 0.0, tormoz * delta)
			else:
				joriy_tezlik = move_toward(joriy_tezlik, -maksimal_tezlik * 0.38, tezlanish * 0.72 * delta)
		else:
			joriy_tezlik = move_toward(joriy_tezlik, 0.0, 3.2 * delta)
		if Input.is_action_pressed("qol_tormozi"):
			joriy_tezlik = move_toward(joriy_tezlik, 0.0, tormoz * 1.8 * delta)
	else:
		joriy_tezlik = move_toward(joriy_tezlik, 0.0, 5.5 * delta)

	if abs(joriy_tezlik) > 0.35:
		var tezlik_nisbati: float = clampf(abs(joriy_tezlik) / maksimal_tezlik, 0.18, 1.0)
		var rul_samarasi: float = lerpf(1.0, 0.45, tezlik_nisbati)
		rotate_y(rul * burilish_tezligi * rul_samarasi * delta * sign(joriy_tezlik))
	rul_burchagi = lerpf(rul_burchagi, rul * 0.48, clampf(delta * 7.5, 0.0, 1.0))
	for pivot in old_gildirak_pivotlari:
		pivot.rotation.y = rul_burchagi
	for gildirak in barcha_gildiraklar:
		gildirak.rotate_x(joriy_tezlik * delta / 0.39)
	kuzov_root.rotation.z = lerpf(kuzov_root.rotation.z, -rul * abs(joriy_tezlik) / maksimal_tezlik * 0.045, delta * 4.5)
	kuzov_root.rotation.x = lerpf(kuzov_root.rotation.x, -gaz * 0.018, delta * 4.0)

	var old := -global_transform.basis.z
	velocity.x = old.x * joriy_tezlik
	velocity.z = old.z * joriy_tezlik
	var zarba_tezligi: float = absf(joriy_tezlik)
	move_and_slide()
	_urilishni_tekshir(zarba_tezligi)

func _urilishni_tekshir(zarba_tezligi: float) -> void:
	if zarba_sovush_vaqti > 0.0 or zarba_tezligi < 3.6 or get_slide_collision_count() == 0:
		return
	var eng_kuchli := 0
	for i in range(get_slide_collision_count()):
		var toqnashuv := get_slide_collision(i)
		var nishon = toqnashuv.get_collider()
		var kuch := maxi(1, int((zarba_tezligi - 2.5) * 3.4))
		eng_kuchli = maxi(eng_kuchli, kuch)
		if is_instance_valid(nishon) and nishon != haydovchi and nishon.has_method("zarar_ol"):
			var tashqi_zarar := int(zarba_tezligi * (7.5 if nishon.is_in_group("piyoda") else 2.8))
			nishon.zarar_ol(maxi(1, tashqi_zarar), self)
	if eng_kuchli > 0:
		zarar_sovush_va_tezlik(eng_kuchli)

func zarar_sovush_va_tezlik(miqdor: int) -> void:
	zarba_sovush_vaqti = 0.42
	zarar_ol(miqdor)
	joriy_tezlik *= 0.42
	if boshqarilmoqda and is_instance_valid(haydovchi) and miqdor >= 8:
		haydovchi.zarar_ol(maxi(1, int(miqdor * 0.42)), self)

func zarar_ol(miqdor: int, _manba = null) -> void:
	if vayron or miqdor <= 0:
		return
	mustahkamlik = maxi(0, mustahkamlik - miqdor)
	mustahkamlik_ozgardi.emit(mustahkamlik)
	if mustahkamlik <= 0:
		_vayron_bolish()

func _vayron_bolish() -> void:
	vayron = true
	joriy_tezlik = 0.0
	var ogohlantirish := Label3D.new()
	ogohlantirish.name = "NosozYozuvi"
	ogohlantirish.text = "NOSOZ"
	ogohlantirish.font_size = 30
	ogohlantirish.outline_size = 6
	ogohlantirish.modulate = Color("ff5d4c")
	ogohlantirish.position = Vector3(0, 2.7, 0)
	ogohlantirish.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(ogohlantirish)
	vayron_boldi.emit()
	if boshqarilmoqda:
		chiqish()

func tiklash() -> void:
	vayron = false
	mustahkamlik = maksimal_mustahkamlik
	joriy_tezlik = 0.0
	var yozuv := get_node_or_null("NosozYozuvi")
	if is_instance_valid(yozuv):
		yozuv.queue_free()
	mustahkamlik_ozgardi.emit(mustahkamlik)

func kirish(oyinchi: CharacterBody3D) -> void:
	if boshqarilmoqda or vayron:
		return
	boshqarilmoqda = true
	haydovchi = oyinchi
	_eshik_animatsiyasi(true)
	oyinchi.transportga_otir(self)
	haydovchi_modeli.visible = true
	haydovchi_kirdi.emit()

func chiqish() -> void:
	if not boshqarilmoqda or not is_instance_valid(haydovchi):
		return
	if abs(joriy_tezlik) > 1.4:
		return
	var chiqish_nuqta := global_position - global_transform.basis.x * 2.0 + Vector3.UP * 0.18
	var eski_haydovchi := haydovchi
	boshqarilmoqda = false
	haydovchi = null
	haydovchi_modeli.visible = false
	_eshik_animatsiyasi(false)
	eski_haydovchi.transportdan_tush(chiqish_nuqta, rotation.y)
	haydovchi_chiqdi.emit()

func _eshik_animatsiyasi(_kirishmi: bool) -> void:
	if not is_instance_valid(eshik_pivot):
		return
	var tween := create_tween()
	tween.tween_property(eshik_pivot, "rotation:y", deg_to_rad(-68.0), 0.28).set_trans(Tween.TRANS_QUAD)
	tween.tween_interval(0.34)
	tween.tween_property(eshik_pivot, "rotation:y", 0.0, 0.32).set_trans(Tween.TRANS_QUAD)

func tezlik_kmh() -> int:
	return int(abs(joriy_tezlik) * 3.6)

func _material(rang: Color, roughness := 0.72, metallic := 0.0) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = rang
	mat.roughness = roughness
	mat.metallic = metallic
	return mat

func _oyna_material() -> StandardMaterial3D:
	var mat := _material(Color(0.055, 0.12, 0.17, 0.78), 0.18, 0.28)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return mat

func _emissive(rang: Color, kuch: float) -> StandardMaterial3D:
	var mat := _material(rang, 0.22)
	mat.emission_enabled = true
	mat.emission = rang
	mat.emission_energy_multiplier = kuch
	return mat

func _quti(parent: Node3D, nom: String, p: Vector3, hajm: Vector3, mat: Material) -> MeshInstance3D:
	var n := MeshInstance3D.new()
	n.name = nom
	var mesh := BoxMesh.new()
	mesh.size = hajm
	n.mesh = mesh
	n.position = p
	n.material_override = mat
	parent.add_child(n)
	return n

func _silindr(parent: Node3D, nom: String, p: Vector3, radius: float, uzunlik: float, mat: Material) -> MeshInstance3D:
	var n := MeshInstance3D.new()
	n.name = nom
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = uzunlik
	n.mesh = mesh
	n.position = p
	n.material_override = mat
	parent.add_child(n)
	return n

func _sfera(parent: Node3D, nom: String, p: Vector3, masshtab: Vector3, mat: Material) -> MeshInstance3D:
	var n := MeshInstance3D.new()
	n.name = nom
	var mesh := SphereMesh.new()
	mesh.radius = 0.5
	mesh.height = 1.0
	n.mesh = mesh
	n.position = p
	n.scale = masshtab
	n.material_override = mat
	parent.add_child(n)
	return n

func _kapsula(parent: Node3D, nom: String, p: Vector3, radius: float, balandlik: float, mat: Material) -> MeshInstance3D:
	var n := MeshInstance3D.new()
	n.name = nom
	var mesh := CapsuleMesh.new()
	mesh.radius = radius
	mesh.height = balandlik
	n.mesh = mesh
	n.position = p
	n.material_override = mat
	parent.add_child(n)
	return n

func _torus(parent: Node3D, nom: String, p: Vector3, radius: float, qalinlik: float, mat: Material) -> MeshInstance3D:
	var n := MeshInstance3D.new()
	n.name = nom
	var mesh := TorusMesh.new()
	mesh.inner_radius = radius - qalinlik
	mesh.outer_radius = radius
	n.mesh = mesh
	n.position = p
	n.material_override = mat
	parent.add_child(n)
	return n
