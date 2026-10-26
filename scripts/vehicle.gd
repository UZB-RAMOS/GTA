extends CharacterBody3D

const YOL_SATHI := -0.10
const MAKSIMAL_TEZLIK_KMH := 140.0
const MAKSIMAL_TEZLIK_M_S := MAKSIMAL_TEZLIK_KMH / 3.6
const VehicleExitHelper = preload("res://scripts/vehicle_exit_helper.gd")

signal haydovchi_kirdi
signal haydovchi_chiqdi
signal mustahkamlik_ozgardi(qiymat)
signal vayron_boldi

@export var maksimal_tezlik := MAKSIMAL_TEZLIK_M_S
@export var tezlanish := 16.5
@export var tormoz := 28.0
@export var erkin_sekinlashish := 1.35
@export var burilish_tezligi := 1.65
@export var kuzov_rangi := Color("1769aa")
@export var buzilmas := true
@export var transport_turi := "sedan"
@export var transport_id := "j_m_j_shahar_sedani"

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
var tiklash_timeri: Timer

func _ready() -> void:
	add_to_group("transport")
	collision_layer = 4
	collision_mask = 1 | 2 | 4 | 8
	motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED
	up_direction = Vector3.UP
	floor_snap_length = 0.45
	floor_stop_on_slope = true
	safe_margin = 0.04
	_yarat_kuzov()
	_model_profilini_qollash()
	tiklash_timeri = Timer.new()
	tiklash_timeri.name = "AvtomatikTamir"
	tiklash_timeri.one_shot = true
	tiklash_timeri.wait_time = 4.5
	tiklash_timeri.timeout.connect(tiklash)
	add_child(tiklash_timeri)

func _yarat_kuzov() -> void:
	var collider := CollisionShape3D.new()
	var shakl := BoxShape3D.new()
	shakl.size = Vector3(1.92, 1.28, 4.12)
	collider.shape = shakl
	collider.position.y = 0.74
	add_child(collider)

	kuzov_root = Node3D.new()
	kuzov_root.name = "JMJShaharSedani"
	add_child(kuzov_root)
	var kuzov := _material(kuzov_rangi, 0.48, 0.68)
	var quyuq_kuzov := _material(kuzov_rangi.darkened(0.16), 0.55, 0.62)
	var qora := _material(Color("11161b"), 0.72)
	var metall := _material(Color("aab2b7"), 0.28, 0.82)
	var oyna := _oyna_material()

	_quti(kuzov_root, "Shassi", Vector3(0, 0.43, 0.08), Vector3(1.93, 0.38, 4.02), quyuq_kuzov)
	_quti(kuzov_root, "AsosiyKuzov", Vector3(0, 0.76, 0.24), Vector3(1.88, 0.62, 3.52), kuzov)
	_quti(kuzov_root, "OldKaput", Vector3(0, 0.94, -1.58), Vector3(1.84, 0.32, 0.96), kuzov)
	_quti(kuzov_root, "OrqaBagaj", Vector3(0, 0.91, 1.66), Vector3(1.82, 0.28, 0.64), kuzov)
	_quti(kuzov_root, "Kabina", Vector3(0, 1.29, 0.23), Vector3(1.72, 0.60, 2.08), kuzov)
	_quti(kuzov_root, "Tom", Vector3(0, 1.63, 0.29), Vector3(1.67, 0.11, 1.82), quyuq_kuzov)
	_quti(kuzov_root, "OldBamper", Vector3(0, 0.38, -2.02), Vector3(2.02, 0.19, 0.18), qora)
	_quti(kuzov_root, "OrqaBamper", Vector3(0, 0.38, 2.08), Vector3(2.02, 0.19, 0.18), qora)
	_quti(kuzov_root, "YuqoriPanjara", Vector3(0, 0.92, -2.057), Vector3(1.24, 0.13, 0.05), qora)
	_quti(kuzov_root, "PastkiPanjara", Vector3(0, 0.72, -2.060), Vector3(1.48, 0.17, 0.05), qora)
	_quti(kuzov_root, "PanjaraAjratgich", Vector3(0, 0.825, -2.090), Vector3(1.54, 0.045, 0.025), metall)
	for x in [-0.50, -0.25, 0.0, 0.25, 0.50]:
		_quti(kuzov_root, "PanjaraChizigi", Vector3(x, 0.72, -2.090), Vector3(0.035, 0.14, 0.025), metall)
	var oltin := _material(Color("c79b37"), 0.30, 0.72)
	_quti(kuzov_root, "MarkaziyBelgi", Vector3(0, 0.92, -2.095), Vector3(0.25, 0.060, 0.025), oltin)
	_quti(kuzov_root, "MarkaziyBelgiTik", Vector3(0, 0.92, -2.098), Vector3(0.070, 0.13, 0.026), oltin)

	# Old va orqa oynalar, yon oynalar.
	_quti(kuzov_root, "OldOyna", Vector3(0, 1.34, -0.82), Vector3(1.50, 0.45, 0.055), oyna)
	_quti(kuzov_root, "OrqaOyna", Vector3(0, 1.32, 1.28), Vector3(1.47, 0.43, 0.055), oyna)
	for x in [-0.875, 0.875]:
		for z in [-0.40, 0.42]:
			_quti(kuzov_root, "YonOyna", Vector3(x, 1.35, z), Vector3(0.055, 0.42, 0.68), oyna)
		_quti(kuzov_root, "YonChiziq", Vector3(x * 1.035, 0.96, 0.36), Vector3(0.045, 0.055, 2.82), metall)

	# Fara, stop chirog‘i, raqam va kuzov choklari.
	for x in [-0.62, 0.62]:
		_quti(kuzov_root, "OldFara", Vector3(x, 1.00, -2.075), Vector3(0.48, 0.16, 0.06), _emissive(Color("fff2bd"), 3.0))
		_quti(kuzov_root, "TumanFarasi", Vector3(x, 0.58, -2.080), Vector3(0.22, 0.12, 0.06), _emissive(Color("ffd99a"), 2.0))
		_quti(kuzov_root, "OrqaChiroq", Vector3(x, 0.84, 2.075), Vector3(0.35, 0.25, 0.055), _emissive(Color("d52e2e"), 1.5))
	_farani_yarat(kuzov_root)
	_quti(kuzov_root, "OldRaqam", Vector3(0, 0.50, -2.115), Vector3(0.62, 0.19, 0.035), _material(Color("f5f4ed"), 0.54))
	_quti(kuzov_root, "OrqaRaqam", Vector3(0, 0.60, 2.115), Vector3(0.62, 0.19, 0.035), _material(Color("f5f4ed"), 0.54))
	for x in [-1.08, 1.08]:
		_quti(kuzov_root, "KozguTayanchi", Vector3(x, 1.29, -0.68), Vector3(0.24, 0.07, 0.07), qora)
		_quti(kuzov_root, "Kozgu", Vector3(x * 1.035, 1.31, -0.68), Vector3(0.13, 0.22, 0.28), quyuq_kuzov)
	for x in [-0.96, 0.96]:
		_quti(kuzov_root, "YonRelief", Vector3(x, 0.90, 0.20), Vector3(0.035, 0.055, 2.95), metall)

	# Chap old eshik alohida pivotda ochiladi.
	eshik_pivot = Node3D.new()
	eshik_pivot.name = "HaydovchiEshigi"
	eshik_pivot.position = Vector3(-0.955, 0.98, -0.62)
	kuzov_root.add_child(eshik_pivot)
	_quti(eshik_pivot, "EshikPaneli", Vector3(-0.015, 0, 0.31), Vector3(0.07, 0.68, 0.72), kuzov)
	_quti(eshik_pivot, "Tutqich", Vector3(-0.075, 0.16, 0.48), Vector3(0.06, 0.06, 0.18), metall)

	# To‘rt g‘ildirak: shina, disk va old g‘ildirak rul pivoti.
	for x in [-0.96, 0.96]:
		for z in [-1.34, 1.35]:
			var pivot := Node3D.new()
			pivot.position = Vector3(x, 0.39, z)
			kuzov_root.add_child(pivot)
			var shina := _silindr(pivot, "Shina", Vector3.ZERO, 0.35, 0.29, qora)
			shina.rotation.z = PI / 2.0
			var disk := _silindr(pivot, "Disk", Vector3(x * 0.025, 0, 0), 0.18, 0.31, metall)
			disk.rotation.z = PI / 2.0
			barcha_gildiraklar.append(shina)
			if z < 0.0:
				old_gildirak_pivotlari.append(pivot)

	# Ichki salon, o‘rindiqlar, rul va ko‘rinadigan haydovchi.
	_quti(kuzov_root, "Panel", Vector3(0, 1.07, -0.72), Vector3(1.55, 0.16, 0.30), qora)
	_quti(kuzov_root, "ChapOrindiq", Vector3(-0.46, 0.83, -0.18), Vector3(0.55, 0.34, 0.62), _material(Color("34383b")))
	_quti(kuzov_root, "OngOrindiq", Vector3(0.46, 0.83, -0.18), Vector3(0.55, 0.34, 0.62), _material(Color("34383b")))
	var rul := _torus(kuzov_root, "Rul", Vector3(-0.47, 1.19, -0.61), 0.20, 0.032, qora)
	rul.rotation.x = deg_to_rad(68.0)
	haydovchi_modeli = _haydovchi_yarat()
	haydovchi_modeli.visible = false
	kuzov_root.add_child(haydovchi_modeli)

func _haydovchi_yarat() -> Node3D:
	var root := Node3D.new()
	root.name = "KorinadiganHaydovchi"
	# Bosh va gavda kabina tomidan chiqib ketmasligi uchun o‘rindiq sathiga mos pastroq siluet.
	root.position = Vector3(-0.46, 0.42, -0.18)
	var teri := _material(Color("c88d66"), 0.9)
	var kiyim := _material(Color("2b73bd"), 0.82)
	_quti(root, "Gavda", Vector3(0, 0.36, 0.05), Vector3(0.46, 0.54, 0.30), kiyim)
	_sfera(root, "Bosh", Vector3(0, 0.78, -0.04), Vector3(0.39, 0.42, 0.38), teri)
	for x in [-0.25, 0.25]:
		var qol := _kapsula(root, "Qol", Vector3(x, 0.35, -0.28), 0.07, 0.48, teri)
		qol.rotation.x = deg_to_rad(68.0)
	return root

func _physics_process(delta: float) -> void:
	zarba_sovush_vaqti = maxf(0.0, zarba_sovush_vaqti - delta)
	if global_position.y < -2.0:
		global_position.y = YOL_SATHI
		rotation.x = 0.0
		rotation.z = 0.0
		tiklash()
	if not is_on_floor():
		velocity.y -= gravitatsiya * delta
	else:
		velocity.y = -0.25

	var gaz := 0.0
	var rul := 0.0
	if boshqarilmoqda and not vayron:
		gaz = Input.get_axis("orqaga", "oldinga")
		rul = Input.get_axis("ong", "chap")
		boshqaruv_tezligini_yangila(gaz, Input.is_action_pressed("qol_tormozi"), delta)
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
		gildirak.rotate_x(joriy_tezlik * delta / 0.35)
	kuzov_root.rotation.z = lerpf(kuzov_root.rotation.z, -rul * abs(joriy_tezlik) / maksimal_tezlik * 0.045, delta * 4.5)
	kuzov_root.rotation.x = lerpf(kuzov_root.rotation.x, -gaz * 0.018, delta * 4.0)

	var old := -global_transform.basis.z
	velocity.x = old.x * joriy_tezlik
	velocity.z = old.z * joriy_tezlik
	var zarba_tezligi: float = absf(joriy_tezlik)
	move_and_slide()
	if global_position.y > 0.08 or global_position.y < -0.35:
		global_position.y = YOL_SATHI
		velocity.y = -0.25
	rotation.x = 0.0
	rotation.z = 0.0
	_urilishni_tekshir(zarba_tezligi)

func boshqaruv_tezligini_yangila(gaz: float, qol_tormozi_bosildi: bool, delta: float) -> void:
	if gaz > 0.0:
		joriy_tezlik = move_toward(joriy_tezlik, maksimal_tezlik, tezlanish * delta)
	elif gaz < 0.0:
		if joriy_tezlik > 1.0:
			joriy_tezlik = move_toward(joriy_tezlik, 0.0, tormoz * delta)
		else:
			joriy_tezlik = move_toward(joriy_tezlik, -maksimal_tezlik * 0.38, tezlanish * 0.72 * delta)
	else:
		joriy_tezlik = move_toward(joriy_tezlik, 0.0, erkin_sekinlashish * delta)
	if qol_tormozi_bosildi:
		joriy_tezlik = move_toward(joriy_tezlik, 0.0, tormoz * 1.8 * delta)

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
			var tashqi_zarar := piyoda_urilish_zarari_hisobla(zarba_tezligi) if nishon.is_in_group("piyoda") else maxi(1, int(zarba_tezligi * 2.8))
			if tashqi_zarar > 0:
				nishon.zarar_ol(tashqi_zarar, self)
	if eng_kuchli > 0:
		zarar_sovush_va_tezlik(eng_kuchli)

func zarar_sovush_va_tezlik(miqdor: int) -> void:
	zarba_sovush_vaqti = 0.42
	zarar_ol(miqdor)

func salon_zarari_hisobla(_toqnashuv_zarari: int) -> int:
	# O‘yinchi transport ichida bo‘lsa, har qanday to‘qnashuvda jon yo‘qotmaydi.
	return 0

func piyoda_urilish_zarari_hisobla(tezlik_m_s: float) -> int:
	# Past tezlik tegib ketish hisoblanadi, yuqori tezlik xavfli, ammo bir kadrda cheksiz zarar yo‘q.
	if tezlik_m_s < 4.0:
		return 0
	return clampi(int(round((tezlik_m_s - 4.0) * 5.0)), 1, 70)

func zarar_ol(miqdor: int, _manba = null) -> void:
	if buzilmas:
		mustahkamlik = maksimal_mustahkamlik
		vayron = false
		mustahkamlik_ozgardi.emit(mustahkamlik)
		return
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
	ogohlantirish.text = "AVTO TA’MIRLANMOQDA"
	ogohlantirish.font_size = 30
	ogohlantirish.outline_size = 6
	ogohlantirish.modulate = Color("ff5d4c")
	ogohlantirish.position = Vector3(0, 2.15, 0)
	ogohlantirish.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(ogohlantirish)
	vayron_boldi.emit()
	if is_instance_valid(tiklash_timeri):
		tiklash_timeri.start()
	if boshqarilmoqda:
		chiqish()

func tiklash() -> void:
	if is_instance_valid(tiklash_timeri):
		tiklash_timeri.stop()
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
	var xavfsiz_joy := _xavfsiz_chiqish_nuqtasi()
	if xavfsiz_joy.is_empty():
		return
	var chiqish_nuqta: Vector3 = xavfsiz_joy.joy
	var eski_haydovchi := haydovchi
	boshqarilmoqda = false
	haydovchi = null
	haydovchi_modeli.visible = false
	_eshik_animatsiyasi(false)
	eski_haydovchi.transportdan_tush(chiqish_nuqta, rotation.y)
	haydovchi_chiqdi.emit()

func _xavfsiz_chiqish_nuqtasi() -> Dictionary:
	return VehicleExitHelper.xavfsiz_nuqta_topish(self, haydovchi, 2.05, 2.45)

func _eshik_animatsiyasi(_kirishmi: bool) -> void:
	if not is_instance_valid(eshik_pivot):
		return
	var tween := create_tween()
	tween.tween_property(eshik_pivot, "rotation:y", deg_to_rad(-68.0), 0.28).set_trans(Tween.TRANS_QUAD)
	tween.tween_interval(0.34)
	tween.tween_property(eshik_pivot, "rotation:y", 0.0, 0.32).set_trans(Tween.TRANS_QUAD)

func tezlik_kmh() -> int:
	return int(abs(joriy_tezlik) * 3.6)

func salon_silueti_ichidami() -> bool:
	var bosh := haydovchi_modeli.get_node_or_null("Bosh") as Node3D if is_instance_valid(haydovchi_modeli) else null
	var kabina := kuzov_root.get_node_or_null("Kabina") as Node3D if is_instance_valid(kuzov_root) else null
	if not is_instance_valid(bosh) or not is_instance_valid(kabina):
		return false
	# Boshning yuqori nuqtasi kabinaning yuqori chetidan pastda qoladi.
	return haydovchi_modeli.position.y + bosh.position.y + 0.21 <= kabina.position.y + 0.30

func _model_profilini_qollash() -> void:
	var profillar := {
		"sedan": Vector3(1.0, 1.0, 1.0),
		"hatchback": Vector3(0.98, 1.02, 0.87),
		"sport": Vector3(1.07, 0.82, 1.06),
		"suv": Vector3(1.10, 1.22, 1.08),
		"minivan": Vector3(1.12, 1.25, 1.25)
	}
	var masshtab: Vector3 = profillar.get(transport_turi, Vector3.ONE)
	if is_instance_valid(kuzov_root):
		kuzov_root.scale = masshtab
		kuzov_root.name = "JMJ_" + transport_turi.capitalize()
	var collider := get_node_or_null("CollisionShape3D") as CollisionShape3D
	if is_instance_valid(collider) and collider.shape is BoxShape3D:
		collider.shape.size = Vector3(1.92 * masshtab.x, 1.28 * masshtab.y, 4.12 * masshtab.z)
		collider.position.y = 0.74 * masshtab.y
	match transport_turi:
		"sport":
			maksimal_tezlik = maxf(maksimal_tezlik, 82.0)
			tezlanish = maxf(tezlanish, 19.0)
		"suv":
			maksimal_tezlik = maxf(maksimal_tezlik, 68.0)
			maksimal_mustahkamlik = 210
			mustahkamlik = maksimal_mustahkamlik
		"hatchback":
			burilish_tezligi = maxf(burilish_tezligi, 1.82)
	# Har qanday profil yoki tashqi qiymat boshqariladigan transportni 140 km/soatdan oshira olmaydi.
	maksimal_tezlik = minf(maksimal_tezlik, MAKSIMAL_TEZLIK_M_S)

func transport_holati_ol() -> Dictionary:
	return {
		"id": transport_id,
		"type": transport_turi,
		"position": [global_position.x, global_position.y, global_position.z],
		"rotation_y": rotation.y,
		"durability": mustahkamlik
	}

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

func _farani_yarat(parent: Node3D) -> void:
	var fara := SpotLight3D.new()
	fara.name = "OldYoritgich"
	fara.position = Vector3(0, 0.88, -2.08)
	fara.light_color = Color("fff0c5")
	fara.light_energy = 4.2
	fara.spot_range = 28.0
	fara.spot_angle = 33.0
	fara.spot_attenuation = 1.05
	fara.shadow_enabled = false
	fara.distance_fade_enabled = true
	fara.distance_fade_begin = 42.0
	fara.distance_fade_length = 18.0
	fara.add_to_group("avtomobil_farasi")
	parent.add_child(fara)

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
	mesh.radial_segments = 18
	mesh.rings = 1
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
	mesh.radial_segments = 16
	mesh.rings = 8
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
	mesh.radial_segments = 14
	mesh.rings = 4
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
	mesh.rings = 18
	mesh.ring_segments = 8
	n.mesh = mesh
	n.position = p
	n.material_override = mat
	parent.add_child(n)
	return n
