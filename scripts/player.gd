extends CharacterBody3D

signal transportga_kirdi(transport)
signal transportdan_chiqdi
signal zarar_oldi(miqdor, manba)
signal hujum_qildi(nishon, miqdor)

const QUROLLAR := {
	"musht": {"nom": "Musht", "zarar": 18, "masofa": 1.85, "sovush": 0.52},
	"tayoq": {"nom": "Metall tayoq", "zarar": 38, "masofa": 2.45, "sovush": 0.68},
	"elektroshoker": {"nom": "Elektroshoker", "zarar": 55, "masofa": 2.05, "sovush": 0.95}
}

@export var yurish_tezligi := 5.2
@export var yugurish_tezligi := 8.6
@export var otirib_yurish_tezligi := 2.35
@export var sakrash_kuchi := 6.0
@export var sichqon_sezgirligi := 0.0025

var faol := true
var joriy_transport: CharacterBody3D
var gravitatsiya := 18.0
var kamera_pivot: Node3D
var kamera: Camera3D
var prujina: SpringArm3D
var collider: CollisionShape3D
var vizual_root: Node3D
var gavda_root: Node3D
var oyoq_pivotlari: Array[Node3D] = []
var qol_pivotlari: Array[Node3D] = []
var kapsula_shakli: CapsuleShape3D
var harakat_vaqti := 0.0
var otiribdi := false
var kamera_erkin_vaqt := 0.0
var kamera_yaw_offset := 0.0
var kamera_maqsad_yaw := 0.0
var kamera_maqsad_pitch := deg_to_rad(-12.0)
var inventar: Array[String] = ["musht"]
var faol_qurol := "musht"
var qurol_modellari: Dictionary = {}
var qurol_ushlagich: Node3D
var hujum_sovush_vaqti := 0.0
var hujum_animatsiyasi := 0.0
var hujum_davomiyligi := 0.0
var hujum_zarba_bajarildi := false
var joriy_hujum_sozlamasi: Dictionary = {}
var zarar_immun_vaqti := 0.0
var hayot_vaqti := 0.0

func _ready() -> void:
	name = "Oyinchi"
	add_to_group("oyinchi")
	collision_layer = 2
	collision_mask = 1 | 4 | 8
	motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED
	up_direction = Vector3.UP
	floor_snap_length = 0.42
	floor_max_angle = deg_to_rad(50.0)
	floor_stop_on_slope = true
	safe_margin = 0.035
	_yarat_tana()
	_yarat_kamera()
	kamera_maqsad_yaw = rotation.y
	kamera_pivot.rotation.x = kamera_maqsad_pitch

func _yarat_tana() -> void:
	vizual_root = Node3D.new()
	vizual_root.name = "AnatomikModel"
	add_child(vizual_root)
	gavda_root = Node3D.new()
	gavda_root.name = "GavdaAnimatsiyasi"
	vizual_root.add_child(gavda_root)

	var teri := _material(Color("c88d66"), 0.88)
	var koylak := _material(Color("173957"), 0.83)
	var shim := _material(Color("172433"), 0.92)
	var poyabzal := _material(Color("171a1d"), 0.78)
	var soch_mat := _material(Color("241b18"), 0.96)
	var oq := _material(Color("f4f1e7"), 0.55)
	var qora := _material(Color("181f25"), 0.48)

	_mesh_quti(gavda_root, "Bel", Vector3(0, 0.93, 0), Vector3(0.52, 0.34, 0.32), shim)
	_mesh_quti(gavda_root, "Gavda", Vector3(0, 1.35, 0), Vector3(0.72, 0.68, 0.38), koylak)
	_mesh_kapsula(gavda_root, "Boyin", Vector3(0, 1.77, 0), 0.11, 0.27, teri)
	_mesh_sfera(gavda_root, "Bosh", Vector3(0, 2.02, -0.01), Vector3(0.58, 0.66, 0.57), teri)
	_mesh_sfera(gavda_root, "Soch", Vector3(0, 2.22, 0.02), Vector3(0.60, 0.28, 0.58), soch_mat)
	_mesh_sfera(gavda_root, "ChapKoz", Vector3(-0.105, 2.06, -0.282), Vector3(0.075, 0.055, 0.035), oq)
	_mesh_sfera(gavda_root, "OngKoz", Vector3(0.105, 2.06, -0.282), Vector3(0.075, 0.055, 0.035), oq)
	_mesh_sfera(gavda_root, "ChapQorachiq", Vector3(-0.105, 2.06, -0.303), Vector3(0.025, 0.028, 0.018), qora)
	_mesh_sfera(gavda_root, "OngQorachiq", Vector3(0.105, 2.06, -0.303), Vector3(0.025, 0.028, 0.018), qora)
	for x in [-0.105, 0.105]:
		var qosh := _mesh_quti(gavda_root, "Qosh", Vector3(x, 2.135, -0.306), Vector3(0.11, 0.025, 0.018), soch_mat)
		qosh.rotation.z = deg_to_rad(5.0 * sign(x))
	for x in [-0.292, 0.292]:
		_mesh_sfera(gavda_root, "Quloq", Vector3(x, 2.02, -0.005), Vector3(0.075, 0.14, 0.055), teri)
	_mesh_kapsula(gavda_root, "Burun", Vector3(0, 1.99, -0.303), 0.035, 0.13, teri, Vector3(deg_to_rad(72), 0, 0))
	_mesh_quti(gavda_root, "Ogiz", Vector3(0, 1.89, -0.296), Vector3(0.13, 0.025, 0.018), _material(Color("80443d")))
	_mesh_quti(gavda_root, "KoylakYoqasi", Vector3(0, 1.66, -0.202), Vector3(0.30, 0.10, 0.025), _material(Color("d5d8d6"), 0.8))
	for y in [1.48, 1.31, 1.14]:
		_mesh_sfera(gavda_root, "Tugma", Vector3(0, y, -0.197), Vector3(0.035, 0.035, 0.018), qora)

	for tomon in [-1.0, 1.0]:
		var qol_pivot := Node3D.new()
		qol_pivot.name = "ChapQol" if tomon < 0 else "OngQol"
		qol_pivot.position = Vector3(tomon * 0.43, 1.62, 0)
		gavda_root.add_child(qol_pivot)
		_mesh_kapsula(qol_pivot, "YuqoriQol", Vector3(0, -0.28, 0), 0.105, 0.60, koylak)
		_mesh_kapsula(qol_pivot, "Bilak", Vector3(0, -0.66, 0), 0.09, 0.45, teri)
		_mesh_sfera(qol_pivot, "Kaft", Vector3(0, -0.91, -0.015), Vector3(0.19, 0.23, 0.15), teri)
		qol_pivotlari.append(qol_pivot)

		var oyoq_pivot := Node3D.new()
		oyoq_pivot.name = "ChapOyoq" if tomon < 0 else "OngOyoq"
		oyoq_pivot.position = Vector3(tomon * 0.19, 0.90, 0)
		gavda_root.add_child(oyoq_pivot)
		_mesh_kapsula(oyoq_pivot, "Son", Vector3(0, -0.31, 0), 0.145, 0.68, shim)
		_mesh_kapsula(oyoq_pivot, "Boldir", Vector3(0, -0.77, 0), 0.12, 0.55, shim)
		_mesh_quti(oyoq_pivot, "Poyabzal", Vector3(0, -1.06, -0.08), Vector3(0.29, 0.18, 0.46), poyabzal)
		oyoq_pivotlari.append(oyoq_pivot)
	_qurollarni_yarat(qol_pivotlari[1])

	collider = CollisionShape3D.new()
	kapsula_shakli = CapsuleShape3D.new()
	kapsula_shakli.radius = 0.39
	kapsula_shakli.height = 1.80
	collider.shape = kapsula_shakli
	collider.position.y = 0.92
	add_child(collider)

func _yarat_kamera() -> void:
	kamera_pivot = Node3D.new()
	kamera_pivot.name = "KameraPivot"
	kamera_pivot.position = Vector3(0, 1.58, 0)
	add_child(kamera_pivot)
	prujina = SpringArm3D.new()
	prujina.name = "KameraMasofa"
	prujina.spring_length = 6.4
	prujina.margin = 0.24
	prujina.collision_mask = 1 | 4
	kamera_pivot.add_child(prujina)
	kamera = Camera3D.new()
	kamera.name = "AsosiyKamera"
	kamera.current = true
	kamera.fov = 68.0
	prujina.add_child(kamera)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if faol:
			kamera_maqsad_yaw -= event.relative.x * sichqon_sezgirligi
		else:
			kamera_yaw_offset = clampf(kamera_yaw_offset - event.relative.x * sichqon_sezgirligi, -PI * 0.72, PI * 0.72)
			kamera_erkin_vaqt = 1.15
		kamera_maqsad_pitch = clampf(
			kamera_maqsad_pitch - event.relative.y * sichqon_sezgirligi,
			deg_to_rad(-52.0), deg_to_rad(28.0)
		)
	if event.is_action_pressed("ozaro"):
		if faol:
			_transport_qidir()
		elif is_instance_valid(joriy_transport):
			joriy_transport.chiqish()
	if event.is_action_pressed("hujum") and faol:
		_hujum()
	if event.is_action_pressed("qurol_1"):
		qurol_tanla("musht")
	elif event.is_action_pressed("qurol_2"):
		qurol_tanla("tayoq")
	elif event.is_action_pressed("qurol_3"):
		qurol_tanla("elektroshoker")

func _physics_process(delta: float) -> void:
	hayot_vaqti += delta
	hujum_sovush_vaqti = maxf(0.0, hujum_sovush_vaqti - delta)
	var hujum_oldin := hujum_animatsiyasi
	hujum_animatsiyasi = maxf(0.0, hujum_animatsiyasi - delta)
	if hujum_oldin > 0.0 and not hujum_zarba_bajarildi and hujum_davomiyligi > 0.0:
		var hujum_progressi := 1.0 - hujum_animatsiyasi / hujum_davomiyligi
		if hujum_progressi >= 0.42:
			hujum_zarba_bajarildi = true
			_hujum_zarbasini_ber()
	zarar_immun_vaqti = maxf(0.0, zarar_immun_vaqti - delta)
	if not faol:
		_transport_kamerasi(delta)
		return

	_piyoda_kamerasini_yangila(delta)
	_otirishni_yangila()
	_otirish_holati(delta)
	if not is_on_floor():
		velocity.y -= gravitatsiya * delta
	elif Input.is_action_just_pressed("sakrash") and not otiribdi:
		velocity.y = sakrash_kuchi

	var kiritish := Input.get_vector("chap", "ong", "oldinga", "orqaga")
	var yonalish := (transform.basis * Vector3(kiritish.x, 0, kiritish.y)).normalized()
	var tezlik := otirib_yurish_tezligi if otiribdi else (yugurish_tezligi if Input.is_action_pressed("yugurish") else yurish_tezligi)
	if yonalish.length() > 0.01:
		velocity.x = move_toward(velocity.x, yonalish.x * tezlik, 22.0 * delta)
		velocity.z = move_toward(velocity.z, yonalish.z * tezlik, 22.0 * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, tezlik * delta * 7.0)
		velocity.z = move_toward(velocity.z, 0.0, tezlik * delta * 7.0)
	move_and_slide()
	_harakat_animatsiyasi(delta, Vector2(velocity.x, velocity.z).length(), tezlik)

func _transport_kamerasi(delta: float) -> void:
	if not is_instance_valid(joriy_transport):
		return
	global_position = joriy_transport.global_position + Vector3.UP * 0.42
	kamera_erkin_vaqt = maxf(0.0, kamera_erkin_vaqt - delta)
	if kamera_erkin_vaqt <= 0.0:
		kamera_yaw_offset = lerp_angle(kamera_yaw_offset, 0.0, clampf(delta * 2.7, 0.0, 1.0))
		kamera_maqsad_pitch = lerp_angle(kamera_maqsad_pitch, deg_to_rad(-13.0), clampf(delta * 2.2, 0.0, 1.0))
	kamera_pivot.rotation.x = lerp_angle(kamera_pivot.rotation.x, kamera_maqsad_pitch, clampf(delta * 14.0, 0.0, 1.0))
	rotation.y = joriy_transport.rotation.y + kamera_yaw_offset
	var nisbat: float = clampf(abs(joriy_transport.joriy_tezlik) / maxf(joriy_transport.maksimal_tezlik, 0.1), 0.0, 1.0)
	prujina.spring_length = lerpf(prujina.spring_length, 6.8 + nisbat * 1.7, clampf(delta * 3.5, 0.0, 1.0))
	kamera.fov = lerpf(kamera.fov, 68.0 + nisbat * 8.0, clampf(delta * 3.0, 0.0, 1.0))

func _piyoda_kamerasini_yangila(delta: float) -> void:
	rotation.y = lerp_angle(rotation.y, kamera_maqsad_yaw, clampf(delta * 18.0, 0.0, 1.0))
	kamera_pivot.rotation.x = lerp_angle(kamera_pivot.rotation.x, kamera_maqsad_pitch, clampf(delta * 18.0, 0.0, 1.0))

func _otirishni_yangila() -> void:
	if Input.is_action_pressed("otirish"):
		otiribdi = true
	elif otiribdi and _turishga_joy_bormi():
		otiribdi = false

func _turishga_joy_bormi() -> bool:
	if not is_inside_tree() or not is_instance_valid(collider):
		return true
	var tik_tana := CapsuleShape3D.new()
	tik_tana.radius = 0.39
	tik_tana.height = 1.80
	var sorov := PhysicsShapeQueryParameters3D.new()
	sorov.shape = tik_tana
	sorov.transform = Transform3D(global_transform.basis, global_position + Vector3.UP * 0.92)
	sorov.collision_mask = collision_mask
	sorov.exclude = [get_rid()]
	return get_world_3d().direct_space_state.intersect_shape(sorov, 1).is_empty()

func _otirish_holati(delta: float) -> void:
	var maqsad_y := -0.38 if otiribdi else 0.0
	vizual_root.position.y = lerpf(vizual_root.position.y, maqsad_y, clampf(delta * 12.0, 0.0, 1.0))
	kapsula_shakli.height = 1.16 if otiribdi else 1.80
	collider.position.y = 0.61 if otiribdi else 0.92

func _harakat_animatsiyasi(delta: float, haqiqiy_tezlik: float, maqsad_tezlik: float) -> void:
	var yurmoqda := haqiqiy_tezlik > 0.25 and is_on_floor()
	if yurmoqda:
		harakat_vaqti += delta * (7.2 if maqsad_tezlik < 6.0 else 10.2)
	var kuch: float = clampf(haqiqiy_tezlik / maxf(maqsad_tezlik, 0.1), 0.0, 1.0)
	var qadam := sin(harakat_vaqti) * (0.62 if not otiribdi else 0.28) * kuch if yurmoqda else 0.0
	var hujum_faol := hujum_animatsiyasi > 0.0 and hujum_davomiyligi > 0.0
	var hujum_progressi := 1.0 - hujum_animatsiyasi / hujum_davomiyligi if hujum_faol else 0.0
	for i in range(oyoq_pivotlari.size()):
		var belgi := -1.0 if i == 0 else 1.0
		oyoq_pivotlari[i].rotation.x = lerp_angle(oyoq_pivotlari[i].rotation.x, qadam * belgi + (0.42 if otiribdi else 0.0), delta * 13.0)
		var qol_maqsadi := -qadam * belgi * 0.75 + (-0.25 if otiribdi else 0.0)
		var qol_y := 0.0
		var qol_z := 0.0
		if hujum_faol:
			if i == 1:
				var orqaga_burchak := -1.15 if faol_qurol == "tayoq" else -0.72
				var oldinga_burchak := 1.42 if faol_qurol == "tayoq" else 1.62
				if hujum_progressi < 0.30:
					var t := smoothstep(0.0, 0.30, hujum_progressi)
					qol_maqsadi = lerpf(0.0, orqaga_burchak, t)
					qol_y = lerpf(0.0, -0.34, t)
					qol_z = lerpf(0.0, -0.24, t)
				elif hujum_progressi < 0.58:
					var t := smoothstep(0.30, 0.58, hujum_progressi)
					qol_maqsadi = lerpf(orqaga_burchak, oldinga_burchak, t)
					qol_y = lerpf(-0.34, 0.12, t)
					qol_z = lerpf(-0.24, -0.08, t)
				else:
					var t := smoothstep(0.58, 1.0, hujum_progressi)
					qol_maqsadi = lerpf(oldinga_burchak, 0.0, t)
					qol_y = lerpf(0.12, 0.0, t)
					qol_z = lerpf(-0.08, 0.0, t)
			else:
				qol_maqsadi = 0.82 * sin(PI * hujum_progressi)
				qol_y = 0.16 * sin(PI * hujum_progressi)
				qol_z = 0.20 * sin(PI * hujum_progressi)
		qol_pivotlari[i].rotation.x = lerp_angle(qol_pivotlari[i].rotation.x, qol_maqsadi, delta * 22.0)
		qol_pivotlari[i].rotation.y = lerp_angle(qol_pivotlari[i].rotation.y, qol_y, delta * 22.0)
		qol_pivotlari[i].rotation.z = lerp_angle(qol_pivotlari[i].rotation.z, qol_z, delta * 22.0)
	gavda_root.position.y = (abs(sin(harakat_vaqti * 2.0)) * 0.045 * kuch) if yurmoqda else lerpf(gavda_root.position.y, 0.0, delta * 8.0)
	gavda_root.rotation.z = lerp_angle(gavda_root.rotation.z, sin(harakat_vaqti) * 0.025 * kuch, delta * 10.0)
	var gavda_burilishi := sin(PI * hujum_progressi) * 0.30 if hujum_faol else sin(hayot_vaqti * 0.72) * 0.008
	gavda_root.rotation.y = lerp_angle(gavda_root.rotation.y, gavda_burilishi, delta * 16.0)

func _transport_qidir() -> void:
	var eng_yaqin: Node3D
	var eng_masofa := 3.4
	for transport in get_tree().get_nodes_in_group("transport"):
		if not transport.has_method("kirish"):
			continue
		var masofa := global_position.distance_to(transport.global_position)
		if masofa < eng_masofa and not transport.boshqarilmoqda:
			eng_masofa = masofa
			eng_yaqin = transport
	if eng_yaqin:
		eng_yaqin.kirish(self)
		return
	var yaqin_dokon: Node3D
	eng_masofa = 4.2
	for dokon in get_tree().get_nodes_in_group("dokon"):
		var masofa := global_position.distance_to(dokon.global_position)
		if masofa < eng_masofa and dokon.has_method("ochish"):
			eng_masofa = masofa
			yaqin_dokon = dokon
	if yaqin_dokon:
		yaqin_dokon.ochish(self)
		return
	var yaqin_joy: Node3D
	eng_masofa = 4.2
	for joy in get_tree().get_nodes_in_group("interaktiv_joy"):
		if not joy.has_method("ishlat"):
			continue
		var masofa: float = float(joy.interaksiya_masofasi(self)) if joy.has_method("interaksiya_masofasi") else global_position.distance_to(joy.global_position)
		if masofa < eng_masofa:
			eng_masofa = masofa
			yaqin_joy = joy
	if yaqin_joy:
		yaqin_joy.ishlat(self)
		return
	var yaqin_piyoda: Node3D
	eng_masofa = 3.2
	for piyoda in get_tree().get_nodes_in_group("piyoda"):
		var masofa := global_position.distance_to(piyoda.global_position)
		if masofa < eng_masofa and piyoda.has_method("suhbat"):
			eng_masofa = masofa
			yaqin_piyoda = piyoda
	if yaqin_piyoda:
		yaqin_piyoda.suhbat(self)

func _hujum() -> void:
	if hujum_sovush_vaqti > 0.0 or not QUROLLAR.has(faol_qurol):
		return
	var sozlama: Dictionary = QUROLLAR[faol_qurol]
	hujum_sovush_vaqti = float(sozlama.sovush)
	hujum_davomiyligi = clampf(float(sozlama.sovush) * 0.82, 0.42, 0.66)
	hujum_animatsiyasi = hujum_davomiyligi
	hujum_zarba_bajarildi = false
	joriy_hujum_sozlamasi = sozlama.duplicate()

func _hujum_zarbasini_ber() -> void:
	if joriy_hujum_sozlamasi.is_empty():
		return
	var sozlama := joriy_hujum_sozlamasi
	var bosh := global_position + Vector3.UP * 1.32
	var old := -global_transform.basis.z
	var sorov := PhysicsRayQueryParameters3D.create(bosh, bosh + old * float(sozlama.masofa))
	sorov.collision_mask = 4 | 8
	sorov.exclude = [get_rid()]
	var natija := get_world_3d().direct_space_state.intersect_ray(sorov)
	var nishon = natija.get("collider") if not natija.is_empty() else null
	if not is_instance_valid(nishon):
		var shakl := SphereShape3D.new()
		shakl.radius = 0.44
		var yaqin_sorov := PhysicsShapeQueryParameters3D.new()
		yaqin_sorov.shape = shakl
		yaqin_sorov.transform = Transform3D(Basis.IDENTITY, bosh + old * minf(float(sozlama.masofa) * 0.72, 1.55))
		yaqin_sorov.collision_mask = 4 | 8
		yaqin_sorov.exclude = [get_rid()]
		var yaqinlar := get_world_3d().direct_space_state.intersect_shape(yaqin_sorov, 6)
		if not yaqinlar.is_empty():
			nishon = yaqinlar[0].get("collider")
	if is_instance_valid(nishon) and nishon.has_method("zarar_ol"):
		var miqdor := int(sozlama.zarar)
		nishon.zarar_ol(miqdor, self)
		hujum_qildi.emit(nishon, miqdor)

func zarar_ol(miqdor: int, manba = null) -> void:
	if miqdor <= 0 or zarar_immun_vaqti > 0.0:
		return
	zarar_immun_vaqti = 0.38
	zarar_oldi.emit(miqdor, manba)

func inventar_qosh(id: String) -> void:
	if not QUROLLAR.has(id) or inventar.has(id):
		return
	inventar.append(id)
	qurol_tanla(id)

func inventar_qoy(yangi_inventar: Array, tanlangan: String) -> void:
	inventar.clear()
	for item in yangi_inventar:
		var id := String(item)
		if QUROLLAR.has(id) and not inventar.has(id):
			inventar.append(id)
	if not inventar.has("musht"):
		inventar.push_front("musht")
	qurol_tanla(tanlangan if inventar.has(tanlangan) else "musht")

func qurol_tanla(id: String) -> void:
	if not inventar.has(id):
		return
	faol_qurol = id
	qurol_holatini_yangila()

func qurol_holatini_yangila() -> void:
	for qurol_id in qurol_modellari:
		var model: Node3D = qurol_modellari[qurol_id]
		model.visible = faol and vizual_root.visible and qurol_id == faol_qurol and inventar.has(qurol_id)

func faol_qurol_nomi() -> String:
	return String(QUROLLAR.get(faol_qurol, QUROLLAR.musht).nom)

func _qurollarni_yarat(ong_qol: Node3D) -> void:
	qurol_ushlagich = Node3D.new()
	qurol_ushlagich.name = "OngQolQurolUshlagichi"
	qurol_ushlagich.position = Vector3(0, -0.92, -0.035)
	ong_qol.add_child(qurol_ushlagich)

	var tayoq_root := Node3D.new()
	tayoq_root.name = "MetallTayoq"
	tayoq_root.position = Vector3(0, 0, -0.045)
	tayoq_root.rotation.x = deg_to_rad(7.0)
	qurol_ushlagich.add_child(tayoq_root)
	_mesh_kapsula(tayoq_root, "RezinaTutqich", Vector3(0, -0.10, 0), 0.068, 0.30, _material(Color("20252a"), 0.72))
	_mesh_kapsula(tayoq_root, "MetallQism", Vector3(0, -0.62, 0), 0.052, 0.86, _material(Color("879198"), 0.24))
	_mesh_sfera(tayoq_root, "TayoqUchi", Vector3(0, -1.05, 0), Vector3(0.13, 0.13, 0.13), _material(Color("aeb7bb"), 0.22))
	tayoq_root.visible = false
	qurol_modellari["tayoq"] = tayoq_root

	var shoker_root := Node3D.new()
	shoker_root.name = "Elektroshoker"
	shoker_root.position = Vector3(0, -0.17, -0.10)
	shoker_root.rotation.x = deg_to_rad(6.0)
	qurol_ushlagich.add_child(shoker_root)
	_mesh_quti(shoker_root, "Korpus", Vector3(0, -0.11, 0), Vector3(0.18, 0.38, 0.14), _material(Color("20272b"), 0.55))
	_mesh_quti(shoker_root, "UstkiPanel", Vector3(0, -0.05, -0.08), Vector3(0.12, 0.13, 0.035), _material(Color("38505c"), 0.42))
	for x in [-0.055, 0.055]:
		_mesh_kapsula(shoker_root, "ElektrUchi", Vector3(x, -0.34, 0), 0.018, 0.16, _material(Color("7be8ff"), 0.20))
	shoker_root.visible = false
	qurol_modellari["elektroshoker"] = shoker_root
	qurol_holatini_yangila()

func transportga_otir(transport: CharacterBody3D) -> void:
	faol = false
	joriy_transport = transport
	velocity = Vector3.ZERO
	vizual_root.visible = false
	qurol_holatini_yangila()
	collider.disabled = true
	kamera_yaw_offset = 0.0
	kamera_erkin_vaqt = 0.0
	kamera_maqsad_pitch = kamera_pivot.rotation.x
	prujina.clear_excluded_objects()
	prujina.add_excluded_object(transport.get_rid())
	transportga_kirdi.emit(transport)

func transportdan_tush(chiqish_nuqta: Vector3, transport_burilishi := 0.0) -> void:
	global_position = chiqish_nuqta
	rotation.y = transport_burilishi
	kamera_maqsad_yaw = transport_burilishi
	faol = true
	joriy_transport = null
	vizual_root.visible = true
	qurol_holatini_yangila()
	prujina.spring_length = 6.4
	prujina.clear_excluded_objects()
	kamera.fov = 68.0
	set_deferred("collision_layer", 2)
	collider.set_deferred("disabled", false)
	transportdan_chiqdi.emit()

func holat_ol() -> Dictionary:
	return {"position": [global_position.x, global_position.y, global_position.z], "rotation_y": rotation.y}

func holat_qoy(data: Dictionary) -> void:
	if data.has("position"):
		var p: Array = data.position
		if p.size() >= 3:
			var x := float(p[0])
			var y := float(p[1])
			var z := float(p[2])
			if is_finite(x) and is_finite(y) and is_finite(z):
				global_position = Vector3(clampf(x, -103.0, 103.0), clampf(y, -0.5, 12.0), clampf(z, -103.0, 103.0))
	var saqlangan_burilish := float(data.get("rotation_y", 0.0))
	rotation.y = saqlangan_burilish if is_finite(saqlangan_burilish) else 0.0
	kamera_maqsad_yaw = rotation.y

func _material(rang: Color, roughness := 0.82) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = rang
	mat.roughness = roughness
	return mat

func _mesh_quti(parent: Node3D, nom: String, p: Vector3, hajm: Vector3, mat: Material) -> MeshInstance3D:
	var n := MeshInstance3D.new()
	n.name = nom
	var mesh := BoxMesh.new()
	mesh.size = hajm
	n.mesh = mesh
	n.position = p
	n.material_override = mat
	parent.add_child(n)
	return n

func _mesh_sfera(parent: Node3D, nom: String, p: Vector3, masshtab: Vector3, mat: Material) -> MeshInstance3D:
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

func _mesh_kapsula(parent: Node3D, nom: String, p: Vector3, radius: float, balandlik: float, mat: Material, burilish := Vector3.ZERO) -> MeshInstance3D:
	var n := MeshInstance3D.new()
	n.name = nom
	var mesh := CapsuleMesh.new()
	mesh.radius = radius
	mesh.height = balandlik
	mesh.radial_segments = 14
	mesh.rings = 4
	n.mesh = mesh
	n.position = p
	n.rotation = burilish
	n.material_override = mat
	parent.add_child(n)
	return n
