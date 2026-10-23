extends CharacterBody3D

const YOL_SATHI := -0.10

@export var rang := Color("c54245")
@export var tezlik := 7.0
@export var model_turi := 0
@export var maksimal_tezlik := 52.0
@export var tezlanish := 14.0
@export var tormoz := 30.0
@export var erkin_sekinlashish := 1.35
@export var burilish_tezligi := 1.55
@export var buzilmas := false
var yol: Array[Vector3] = []
var indeks := 0
var joriy_tezlik := 0.0
var gildiraklar: Array[MeshInstance3D] = []
var maksimal_mustahkamlik := 120
var mustahkamlik := 120
var zarba_sovush_vaqti := 0.0
var vayron := false
var tiklanish_vaqti := 0.0
var qotish_vaqti := 0.0
var sezgi_vaqti := 0.0
var toxtash_kerak := false
var boshqarilmoqda := false
var haydovchi: CharacterBody3D

func _ready() -> void:
	add_to_group("trafik")
	add_to_group("transport")
	collision_layer = 4
	collision_mask = 1 | 2 | 4 | 8
	floor_snap_length = 0.45
	up_direction = Vector3.UP
	global_position.y = YOL_SATHI
	_yarat_model()
	sezgi_vaqti = float(get_instance_id() % 12) * 0.015

func _yarat_model() -> void:
	var collider := CollisionShape3D.new()
	var shakl := BoxShape3D.new()
	shakl.size = Vector3(1.74, 1.18, 3.45)
	collider.shape = shakl
	collider.position.y = 0.72
	add_child(collider)
	var kuzov := _material(rang, 0.46, 0.58)
	var quyuq_kuzov := _material(rang.darkened(0.20), 0.52, 0.58)
	var qora := _material(Color("111519"), 0.75)
	var metall := _material(Color("aab0b4"), 0.25, 0.82)
	var oyna := _oyna_material()

	_quti("Shassi", Vector3(0, 0.50, 0), Vector3(1.72, 0.48, 3.38), quyuq_kuzov)
	_quti("Kaput", Vector3(0, 0.83, -1.22), Vector3(1.67, 0.28, 0.95), kuzov)
	_quti("Bagaj", Vector3(0, 0.84, 1.28), Vector3(1.67, 0.30, 0.72), kuzov)
	_quti("Kabina", Vector3(0, 1.18, 0.08), Vector3(1.49, 0.70, 1.55), kuzov)
	_quti("OldOyna", Vector3(0, 1.28, -0.73), Vector3(1.32, 0.48, 0.045), oyna)
	_quti("OrqaOyna", Vector3(0, 1.28, 0.85), Vector3(1.31, 0.46, 0.045), oyna)
	for x in [-0.765, 0.765]:
		_quti("YonOyna", Vector3(x, 1.29, 0.08), Vector3(0.045, 0.44, 1.18), oyna)
		_quti("Kozgu", Vector3(x * 1.11, 1.23, -0.67), Vector3(0.20, 0.16, 0.24), kuzov)
	# Ikki qavatli panjara va tor faralar — O‘zbekiston ko‘chalaridagi zamonaviy
	# sedanlardan ilhomlangan, lekin mustaqil yaratilgan original kuzov.
	_quti("YuqoriPanjara", Vector3(0, 0.82, -1.735), Vector3(1.06, 0.12, 0.045), qora)
	_quti("PastkiPanjara", Vector3(0, 0.64, -1.738), Vector3(1.34, 0.16, 0.045), qora)
	_quti("PanjaraXromi", Vector3(0, 0.735, -1.766), Vector3(1.40, 0.035, 0.022), metall)
	var oltin := _material(Color("c39a3b"), 0.30, 0.70)
	_quti("MarkaziyBelgi", Vector3(0, 0.82, -1.770), Vector3(0.20, 0.050, 0.025), oltin)
	_quti("MarkaziyBelgiTik", Vector3(0, 0.82, -1.772), Vector3(0.060, 0.105, 0.025), oltin)
	for x in [-0.55, 0.55]:
		_quti("Fara", Vector3(x, 0.91, -1.72), Vector3(0.40, 0.14, 0.05), _emissive(Color("fff1ba"), 2.8))
		_quti("TumanFarasi", Vector3(x, 0.55, -1.73), Vector3(0.17, 0.10, 0.05), _emissive(Color("ffd79a"), 1.7))
		_quti("Stop", Vector3(x, 0.79, 1.72), Vector3(0.34, 0.21, 0.05), _emissive(Color("cf3030"), 1.2))
	_farani_yarat()
	_quti("OldBamper", Vector3(0, 0.42, -1.75), Vector3(1.82, 0.18, 0.13), qora)
	_quti("OrqaBamper", Vector3(0, 0.42, 1.75), Vector3(1.82, 0.18, 0.13), qora)
	_quti("Raqam", Vector3(0, 0.60, -1.79), Vector3(0.54, 0.16, 0.025), _material(Color("f5f3e9")))
	for x in [-0.875, 0.875]:
		_quti("YonRelief", Vector3(x, 0.72, 0.05), Vector3(0.025, 0.045, 2.70), metall)
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
	zarba_sovush_vaqti = maxf(0.0, zarba_sovush_vaqti - delta)
	if yol.is_empty() and not boshqarilmoqda:
		return
	if vayron:
		tiklanish_vaqti -= delta
		velocity = Vector3.ZERO
		_yerga_yopishtir()
		if tiklanish_vaqti <= 0.0:
			_avtomatik_tiklash()
		return
	if boshqarilmoqda:
		_oyinchi_boshqaruvi(delta)
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
	sezgi_vaqti -= delta
	if sezgi_vaqti <= 0.0:
		toxtash_kerak = _qizil_chiroq_yaqin() or _oldinda_mashina()
		sezgi_vaqti = 0.18
	var maqsad_tezlik := 0.0 if toxtash_kerak else tezlik
	joriy_tezlik = move_toward(joriy_tezlik, maqsad_tezlik, (10.0 if maqsad_tezlik == 0.0 else 3.0) * delta)
	velocity = -global_transform.basis.z * joriy_tezlik
	velocity.y = -1.5
	var zarba_tezligi: float = absf(joriy_tezlik)
	var oldingi_joy := global_position
	move_and_slide()
	_yerga_yopishtir()
	if maqsad_tezlik > 0.0 and joriy_tezlik > 2.0 and global_position.distance_to(oldingi_joy) < 0.008:
		qotish_vaqti += delta
	else:
		qotish_vaqti = maxf(0.0, qotish_vaqti - delta * 2.0)
	if qotish_vaqti > 3.0:
		_yolga_qaytar()
	_urilishni_tekshir(zarba_tezligi)
	for gildirak in gildiraklar:
		gildirak.rotate_x(joriy_tezlik * delta / 0.34)

func _oyinchi_boshqaruvi(delta: float) -> void:
	var gaz := Input.get_axis("orqaga", "oldinga")
	var rul := Input.get_axis("ong", "chap")
	boshqaruv_tezligini_yangila(gaz, Input.is_action_pressed("qol_tormozi"), delta)
	if absf(joriy_tezlik) > 0.35:
		var tezlik_nisbati := clampf(absf(joriy_tezlik) / maksimal_tezlik, 0.18, 1.0)
		var rul_samarasi := lerpf(1.0, 0.42, tezlik_nisbati)
		rotate_y(rul * burilish_tezligi * rul_samarasi * delta * signf(joriy_tezlik))
	velocity = -global_transform.basis.z * joriy_tezlik
	velocity.y = -1.5
	var zarba_tezligi := absf(joriy_tezlik)
	move_and_slide()
	_yerga_yopishtir()
	_urilishni_tekshir(zarba_tezligi)
	for gildirak in gildiraklar:
		gildirak.rotate_x(joriy_tezlik * delta / 0.34)

func boshqaruv_tezligini_yangila(gaz: float, qol_tormozi_bosildi: bool, delta: float) -> void:
	if gaz > 0.0:
		joriy_tezlik = move_toward(joriy_tezlik, maksimal_tezlik, tezlanish * delta)
	elif gaz < 0.0:
		if joriy_tezlik > 0.5:
			joriy_tezlik = move_toward(joriy_tezlik, 0.0, tormoz * delta)
		else:
			joriy_tezlik = move_toward(joriy_tezlik, -maksimal_tezlik * 0.34, tezlanish * 0.68 * delta)
	else:
		joriy_tezlik = move_toward(joriy_tezlik, 0.0, erkin_sekinlashish * delta)
	if qol_tormozi_bosildi:
		joriy_tezlik = move_toward(joriy_tezlik, 0.0, tormoz * 2.0 * delta)

func _yerga_yopishtir() -> void:
	global_position.y = YOL_SATHI
	rotation.x = 0.0
	rotation.z = 0.0
	velocity.y = -1.5

func _urilishni_tekshir(zarba_tezligi: float) -> void:
	if zarba_sovush_vaqti > 0.0 or zarba_tezligi < 3.4 or get_slide_collision_count() == 0:
		return
	zarba_sovush_vaqti = 0.5
	for i in range(get_slide_collision_count()):
		var nishon = get_slide_collision(i).get_collider()
		if is_instance_valid(nishon) and nishon.has_method("zarar_ol"):
			var zarar := piyoda_urilish_zarari_hisobla(zarba_tezligi) if nishon.is_in_group("piyoda") else maxi(1, int(zarba_tezligi * 2.4))
			if zarar > 0:
				nishon.zarar_ol(zarar, self)
		zarar_ol(maxi(1, int((zarba_tezligi - 2.5) * 2.4)))
	if not boshqarilmoqda:
		joriy_tezlik *= 0.48

func piyoda_urilish_zarari_hisobla(tezlik_m_s: float) -> int:
	if tezlik_m_s < 4.0:
		return 0
	return clampi(int(round((tezlik_m_s - 4.0) * 5.0)), 1, 70)

func zarar_ol(miqdor: int, _manba = null) -> void:
	if vayron or miqdor <= 0:
		return
	mustahkamlik = maxi(0, mustahkamlik - miqdor)
	if mustahkamlik <= 0:
		vayron = true
		joriy_tezlik = 0.0
		if boshqarilmoqda:
			chiqish(true)
		var yozuv := Label3D.new()
		yozuv.name = "TiklanishYozuvi"
		yozuv.text = "TIKLANMOQDA"
		yozuv.font_size = 24
		yozuv.outline_size = 5
		yozuv.modulate = Color("ff5c4d")
		yozuv.position = Vector3(0, 2.15, 0)
		yozuv.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		add_child(yozuv)
		tiklanish_vaqti = 3.5

func _avtomatik_tiklash() -> void:
	vayron = false
	mustahkamlik = maksimal_mustahkamlik
	joriy_tezlik = 0.0
	qotish_vaqti = 0.0
	var yozuv := get_node_or_null("TiklanishYozuvi")
	if is_instance_valid(yozuv):
		yozuv.queue_free()
	_yolga_qaytar()

func _yolga_qaytar() -> void:
	if yol.is_empty():
		return
	global_position = yol[indeks]
	global_position.y = YOL_SATHI
	var keyingi := yol[(indeks + 1) % yol.size()]
	var yonalish := (keyingi - global_position).normalized()
	rotation.y = atan2(-yonalish.x, -yonalish.z)
	indeks = (indeks + 1) % yol.size()
	joriy_tezlik = 0.0
	qotish_vaqti = 0.0
	_yerga_yopishtir()

func kirish(oyinchi: CharacterBody3D) -> void:
	if boshqarilmoqda or vayron:
		return
	boshqarilmoqda = true
	haydovchi = oyinchi
	joriy_tezlik = 0.0
	toxtash_kerak = false
	qotish_vaqti = 0.0
	oyinchi.transportga_otir(self)

func chiqish(majburiy := false) -> void:
	if not boshqarilmoqda or not is_instance_valid(haydovchi):
		return
	if not majburiy and absf(joriy_tezlik) > 1.4:
		return
	var xavfsiz_joy := _xavfsiz_chiqish_nuqtasi()
	if xavfsiz_joy.is_empty() and not majburiy:
		return
	var chiqish_nuqta: Vector3 = xavfsiz_joy.get("joy", global_position + global_transform.basis.x.normalized() * 2.1 + Vector3.UP * 0.18)
	var eski_haydovchi := haydovchi
	boshqarilmoqda = false
	haydovchi = null
	joriy_tezlik = 0.0
	eski_haydovchi.transportdan_tush(chiqish_nuqta, rotation.y)

func _xavfsiz_chiqish_nuqtasi() -> Dictionary:
	var yon := global_transform.basis.x.normalized()
	var old := -global_transform.basis.z.normalized()
	var nomzodlar := [
		global_position - yon * 1.95 + Vector3.UP * 0.18,
		global_position + yon * 1.95 + Vector3.UP * 0.18,
		global_position - old * 2.25 + Vector3.UP * 0.18,
		global_position + old * 2.25 + Vector3.UP * 0.18
	]
	var shakl := CapsuleShape3D.new()
	shakl.radius = 0.42
	shakl.height = 1.80
	for nomzod in nomzodlar:
		var sorov := PhysicsShapeQueryParameters3D.new()
		sorov.shape = shakl
		sorov.transform = Transform3D(Basis.IDENTITY, nomzod + Vector3.UP * 0.92)
		sorov.collision_mask = 1 | 4 | 8
		sorov.exclude = [get_rid(), haydovchi.get_rid()]
		if get_world_3d().direct_space_state.intersect_shape(sorov, 1).is_empty():
			return {"joy": nomzod}
	return {}

func tezlik_kmh() -> int:
	return int(absf(joriy_tezlik) * 3.6)

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
	var avtomobillar := get_tree().get_nodes_in_group("transport")
	for boshqa in avtomobillar:
		if boshqa == self:
			continue
		var lokal := to_local(boshqa.global_position)
		if lokal.z < -0.2 and lokal.z > -5.8 and abs(lokal.x) < 1.30:
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

func _farani_yarat() -> void:
	var fara := SpotLight3D.new()
	fara.name = "OldYoritgich"
	fara.position = Vector3(0, 0.84, -1.73)
	fara.light_color = Color("fff0c5")
	fara.light_energy = 3.4
	fara.spot_range = 22.0
	fara.spot_angle = 34.0
	fara.spot_attenuation = 1.08
	fara.shadow_enabled = false
	fara.distance_fade_enabled = true
	fara.distance_fade_begin = 36.0
	fara.distance_fade_length = 16.0
	fara.add_to_group("avtomobil_farasi")
	add_child(fara)

func _quti(nom: String, p: Vector3, hajm: Vector3, mat: Material) -> MeshInstance3D:
	var n := MeshInstance3D.new()
	n.name = nom
	var mesh := BoxMesh.new()
	mesh.size = hajm
	n.mesh = mesh
	n.position = p
	n.material_override = mat
	n.visibility_range_end = 76.0
	add_child(n)
	return n

func _silindr(p: Vector3, radius: float, uzunlik: float, mat: Material) -> MeshInstance3D:
	var n := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = uzunlik
	mesh.radial_segments = 16
	mesh.rings = 1
	n.mesh = mesh
	n.position = p
	n.material_override = mat
	n.visibility_range_end = 76.0
	add_child(n)
	return n

func _sfera(nom: String, p: Vector3, masshtab: Vector3, mat: Material) -> MeshInstance3D:
	var n := MeshInstance3D.new()
	n.name = nom
	var mesh := SphereMesh.new()
	mesh.radius = 0.5
	mesh.height = 1.0
	mesh.radial_segments = 14
	mesh.rings = 7
	n.mesh = mesh
	n.position = p
	n.scale = masshtab
	n.material_override = mat
	n.visibility_range_end = 76.0
	add_child(n)
	return n
