extends CharacterBody3D

signal transportga_kirdi(transport)
signal transportdan_chiqdi

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

func _ready() -> void:
	name = "Oyinchi"
	add_to_group("oyinchi")
	collision_layer = 2
	collision_mask = 1 | 4
	_yarat_tana()
	_yarat_kamera()

func _yarat_tana() -> void:
	vizual_root = Node3D.new()
	vizual_root.name = "AnatomikModel"
	add_child(vizual_root)
	gavda_root = Node3D.new()
	gavda_root.name = "GavdaAnimatsiyasi"
	vizual_root.add_child(gavda_root)

	var teri := _material(Color("c88d66"), 0.88)
	var koylak := _material(Color("2b73bd"), 0.83)
	var shim := _material(Color("26384a"), 0.92)
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
	_mesh_kapsula(gavda_root, "Burun", Vector3(0, 1.99, -0.303), 0.035, 0.13, teri, Vector3(deg_to_rad(72), 0, 0))
	_mesh_quti(gavda_root, "Ogiz", Vector3(0, 1.89, -0.296), Vector3(0.13, 0.025, 0.018), _material(Color("80443d")))

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
	prujina.collision_mask = 1
	kamera_pivot.add_child(prujina)
	kamera = Camera3D.new()
	kamera.name = "AsosiyKamera"
	kamera.current = true
	kamera.fov = 68.0
	prujina.add_child(kamera)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if faol:
			rotate_y(-event.relative.x * sichqon_sezgirligi)
		else:
			kamera_yaw_offset = clampf(kamera_yaw_offset - event.relative.x * sichqon_sezgirligi, -PI * 0.72, PI * 0.72)
			kamera_erkin_vaqt = 1.15
		kamera_pivot.rotation.x = clamp(
			kamera_pivot.rotation.x - event.relative.y * sichqon_sezgirligi,
			deg_to_rad(-52.0), deg_to_rad(28.0)
		)
	if event.is_action_pressed("ozaro"):
		if faol:
			_transport_qidir()
		elif is_instance_valid(joriy_transport):
			joriy_transport.chiqish()

func _physics_process(delta: float) -> void:
	if not faol:
		_transport_kamerasi(delta)
		return

	otiribdi = Input.is_action_pressed("otirish") and is_on_floor()
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
		kamera_pivot.rotation.x = lerp_angle(kamera_pivot.rotation.x, deg_to_rad(-13.0), clampf(delta * 2.2, 0.0, 1.0))
	rotation.y = joriy_transport.rotation.y + kamera_yaw_offset
	var nisbat: float = clampf(abs(joriy_transport.joriy_tezlik) / maxf(joriy_transport.maksimal_tezlik, 0.1), 0.0, 1.0)
	prujina.spring_length = lerpf(prujina.spring_length, 6.8 + nisbat * 1.7, clampf(delta * 3.5, 0.0, 1.0))
	kamera.fov = lerpf(kamera.fov, 68.0 + nisbat * 8.0, clampf(delta * 3.0, 0.0, 1.0))

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
	for i in range(oyoq_pivotlari.size()):
		var belgi := -1.0 if i == 0 else 1.0
		oyoq_pivotlari[i].rotation.x = lerp_angle(oyoq_pivotlari[i].rotation.x, qadam * belgi + (0.42 if otiribdi else 0.0), delta * 13.0)
		qol_pivotlari[i].rotation.x = lerp_angle(qol_pivotlari[i].rotation.x, -qadam * belgi * 0.75 + (-0.25 if otiribdi else 0.0), delta * 13.0)
	gavda_root.position.y = (abs(sin(harakat_vaqti * 2.0)) * 0.045 * kuch) if yurmoqda else lerpf(gavda_root.position.y, 0.0, delta * 8.0)
	gavda_root.rotation.z = lerp_angle(gavda_root.rotation.z, sin(harakat_vaqti) * 0.025 * kuch, delta * 10.0)

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

func transportga_otir(transport: CharacterBody3D) -> void:
	faol = false
	joriy_transport = transport
	velocity = Vector3.ZERO
	vizual_root.visible = false
	collider.disabled = true
	kamera_yaw_offset = 0.0
	kamera_erkin_vaqt = 0.0
	transportga_kirdi.emit(transport)

func transportdan_tush(chiqish_nuqta: Vector3, transport_burilishi := 0.0) -> void:
	global_position = chiqish_nuqta
	rotation.y = transport_burilishi
	faol = true
	joriy_transport = null
	vizual_root.visible = true
	prujina.spring_length = 6.4
	kamera.fov = 68.0
	set_deferred("collision_layer", 2)
	collider.set_deferred("disabled", false)
	transportdan_chiqdi.emit()

func holat_ol() -> Dictionary:
	return {"position": [global_position.x, global_position.y, global_position.z], "rotation_y": rotation.y}

func holat_qoy(data: Dictionary) -> void:
	if data.has("position"):
		var p: Array = data.position
		global_position = Vector3(float(p[0]), float(p[1]), float(p[2]))
	rotation.y = float(data.get("rotation_y", 0.0))

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
	n.mesh = mesh
	n.position = p
	n.rotation = burilish
	n.material_override = mat
	parent.add_child(n)
	return n
