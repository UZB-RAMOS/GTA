extends CharacterBody3D

signal pul_tushdi(joy, miqdor)
signal halok_boldi(piyoda)

@export var rang := Color("d7a93b")
@export var markaz := Vector3.ZERO
@export var radius := 8.0
var maqsad := Vector3.ZERO
var tezlik := 1.65
var rng := RandomNumberGenerator.new()
var model_root: Node3D
var bosh_pivot: Node3D
var oyoqlar: Array[Node3D] = []
var qollar: Array[Node3D] = []
var qadam_vaqti := 0.0
var hayot_vaqti := 0.0
var kutish_vaqti := 0.0
var jon := 75
var olgan := false
var collider: CollisionShape3D
var zarar_immun_vaqti := 0.0
var zarba_vaqti := 0.0
var zarba_tezligi := Vector3.ZERO

func _ready() -> void:
	add_to_group("piyoda")
	collision_layer = 8
	collision_mask = 1
	rng.seed = hash(name)
	tezlik = rng.randf_range(1.25, 2.05)
	jon = rng.randi_range(65, 95)
	_yarat_model()
	_yangi_maqsad()

func _yarat_model() -> void:
	var boy := rng.randf_range(0.92, 1.08)
	collider = CollisionShape3D.new()
	var shakl := CapsuleShape3D.new()
	shakl.radius = 0.31
	shakl.height = 1.62 * boy
	collider.shape = shakl
	collider.position.y = 0.82 * boy
	add_child(collider)

	model_root = Node3D.new()
	model_root.name = "ToliqOdamModeli"
	model_root.scale = Vector3.ONE * boy
	add_child(model_root)
	var terilar := [Color("e1ae83"), Color("c98c63"), Color("9f684c"), Color("e8bc98")]
	var shimlar := [Color("172638"), Color("24282c"), Color("403127"), Color("15243a")]
	var sochlar := [Color("201916"), Color("422b21"), Color("17191b"), Color("6b4932")]
	var teri := _material(terilar[rng.randi_range(0, terilar.size() - 1)], 0.9)
	var kiyim := _material(rang, 0.86)
	var shim := _material(shimlar[rng.randi_range(0, shimlar.size() - 1)], 0.92)
	var soch := _material(sochlar[rng.randi_range(0, sochlar.size() - 1)], 0.96)
	var poyabzal := _material(Color("17191c"), 0.78)

	_quti(model_root, "Bel", Vector3(0, 0.82, 0), Vector3(0.43, 0.27, 0.29), shim)
	_quti(model_root, "Gavda", Vector3(0, 1.17, 0), Vector3(0.58, 0.58, 0.34), kiyim)
	_quti(model_root, "Yoqasi", Vector3(0, 1.46, -0.176), Vector3(0.24, 0.08, 0.022), _material(Color("c8c5b9"), 0.8))
	for y in [1.31, 1.17, 1.03]:
		_sfera(model_root, "Tugma", Vector3(0, y, -0.178), Vector3(0.026, 0.026, 0.014), _material(Color("1a2024"), 0.5))
	_kapsula(model_root, "Boyin", Vector3(0, 1.52, 0), 0.085, 0.22, teri)
	bosh_pivot = Node3D.new()
	bosh_pivot.name = "BoshHarakati"
	bosh_pivot.position = Vector3(0, 1.73, -0.01)
	model_root.add_child(bosh_pivot)
	_sfera(bosh_pivot, "Bosh", Vector3.ZERO, Vector3(0.47, 0.55, 0.46), teri)
	_sfera(bosh_pivot, "Soch", Vector3(0, 0.17, 0.02), Vector3(0.49, 0.24, 0.47), soch)
	var oq := _material(Color("e7e4da"), 0.55)
	var koz_mat := _material(Color("171d20"), 0.38)
	for x in [-0.085, 0.085]:
		_sfera(bosh_pivot, "KozOqi", Vector3(x, 0.03, -0.235), Vector3(0.060, 0.042, 0.022), oq)
		_sfera(bosh_pivot, "Qorachiq", Vector3(x, 0.03, -0.252), Vector3(0.022, 0.025, 0.012), koz_mat)
		var qosh := _quti(bosh_pivot, "Qosh", Vector3(x, 0.10, -0.247), Vector3(0.09, 0.018, 0.012), soch)
		qosh.rotation.z = deg_to_rad(5.0 * sign(x))
	for x in [-0.238, 0.238]:
		_sfera(bosh_pivot, "Quloq", Vector3(x, 0.0, 0), Vector3(0.060, 0.115, 0.045), teri)
	var burun := _kapsula(bosh_pivot, "Burun", Vector3(0, -0.02, -0.248), 0.026, 0.105, teri)
	burun.rotation.x = deg_to_rad(72.0)
	_quti(bosh_pivot, "Ogiz", Vector3(0, -0.10, -0.237), Vector3(0.10, 0.018, 0.015), _material(Color("79433d")))

	for tomon in [-1.0, 1.0]:
		var qol := Node3D.new()
		qol.position = Vector3(tomon * 0.35, 1.42, 0)
		model_root.add_child(qol)
		_kapsula(qol, "YuqoriQol", Vector3(0, -0.25, 0), 0.085, 0.54, kiyim)
		_kapsula(qol, "Bilak", Vector3(0, -0.57, 0), 0.07, 0.34, teri)
		_sfera(qol, "Kaft", Vector3(0, -0.77, 0), Vector3(0.14, 0.18, 0.12), teri)
		qollar.append(qol)

		var oyoq := Node3D.new()
		oyoq.position = Vector3(tomon * 0.15, 0.78, 0)
		model_root.add_child(oyoq)
		_kapsula(oyoq, "Son", Vector3(0, -0.26, 0), 0.12, 0.57, shim)
		_kapsula(oyoq, "Boldir", Vector3(0, -0.64, 0), 0.10, 0.45, shim)
		_quti(oyoq, "Poyabzal", Vector3(0, -0.88, -0.07), Vector3(0.24, 0.16, 0.37), poyabzal)
		oyoqlar.append(oyoq)

func _physics_process(delta: float) -> void:
	zarar_immun_vaqti = maxf(0.0, zarar_immun_vaqti - delta)
	if olgan:
		return
	if zarba_vaqti > 0.0:
		zarba_vaqti = maxf(0.0, zarba_vaqti - delta)
		zarba_tezligi = zarba_tezligi.move_toward(Vector3.ZERO, 10.0 * delta)
		velocity.x = zarba_tezligi.x
		velocity.z = zarba_tezligi.z
		velocity.y = -0.7
		move_and_slide()
		if _animatsiya_kerak():
			_animatsiya(delta, false)
		return
	if kutish_vaqti > 0.0:
		kutish_vaqti -= delta
		velocity = Vector3.ZERO
		if _animatsiya_kerak():
			_animatsiya(delta, false)
		if kutish_vaqti <= 0.0:
			_yangi_maqsad()
		return
	var farq := maqsad - global_position
	farq.y = 0.0
	if farq.length() < 0.75:
		kutish_vaqti = rng.randf_range(0.6, 2.4)
		return
	var yonalish := farq.normalized()
	rotation.y = lerp_angle(rotation.y, atan2(-yonalish.x, -yonalish.z), delta * 4.2)
	velocity.x = yonalish.x * tezlik
	velocity.z = yonalish.z * tezlik
	velocity.y = -0.7
	move_and_slide()
	if _animatsiya_kerak():
		_animatsiya(delta, true)

func _animatsiya_kerak() -> bool:
	var faol_kamera := get_viewport().get_camera_3d()
	return not is_instance_valid(faol_kamera) or global_position.distance_squared_to(faol_kamera.global_position) < 3025.0

func _animatsiya(delta: float, yurmoqda: bool) -> void:
	hayot_vaqti += delta
	if yurmoqda:
		qadam_vaqti += delta * (6.0 + tezlik)
	var qadam := sin(qadam_vaqti) * 0.55 if yurmoqda else 0.0
	for i in range(oyoqqlar_soni()):
		var belgi := -1.0 if i == 0 else 1.0
		oyoqlar[i].rotation.x = lerp_angle(oyoqlar[i].rotation.x, qadam * belgi, delta * 10.0)
		var dam_olish := sin(hayot_vaqti * 1.35 + float(i)) * 0.035
		qollar[i].rotation.x = lerp_angle(qollar[i].rotation.x, -qadam * belgi * 0.7 + dam_olish, delta * 10.0)
	model_root.position.y = abs(sin(qadam_vaqti * 2.0)) * 0.025 if yurmoqda else lerpf(model_root.position.y, 0.0, delta * 5.0)
	model_root.rotation.z = lerp_angle(model_root.rotation.z, sin(hayot_vaqti * 0.72) * 0.012, delta * 2.5)
	if is_instance_valid(bosh_pivot):
		bosh_pivot.rotation.y = lerp_angle(bosh_pivot.rotation.y, sin(hayot_vaqti * 0.48 + float(name.hash() % 11)) * 0.08, delta * 2.0)
		bosh_pivot.rotation.x = lerp_angle(bosh_pivot.rotation.x, sin(hayot_vaqti * 0.36) * 0.025, delta * 2.0)

func oyoqqlar_soni() -> int:
	return mini(oyoqlar.size(), qollar.size())

func _yangi_maqsad() -> void:
	maqsad = markaz + Vector3(rng.randf_range(-radius, radius), 0, rng.randf_range(-radius, radius))

func zarar_ol(miqdor: int, manba = null) -> void:
	if olgan or miqdor <= 0 or zarar_immun_vaqti > 0.0:
		return
	zarar_immun_vaqti = 0.48
	jon -= miqdor
	model_root.rotation.z = deg_to_rad(rng.randf_range(-8.0, 8.0))
	if jon <= 0:
		_halok_bolish()
	elif manba is Node3D:
		var itarish: Vector3 = global_position - manba.global_position
		itarish.y = 0.0
		if itarish.length_squared() > 0.01:
			zarba_tezligi = itarish.normalized() * clampf(1.5 + miqdor * 0.055, 1.5, 5.8)
			zarba_vaqti = 0.30
			kutish_vaqti = maxf(kutish_vaqti, 0.45)

func _halok_bolish() -> void:
	olgan = true
	velocity = Vector3.ZERO
	collision_layer = 0
	collision_mask = 0
	collider.set_deferred("disabled", true)
	var tushadigan_pul := rng.randi_range(1800, 5200)
	pul_tushdi.emit(global_position + Vector3.UP * 0.35, tushadigan_pul)
	halok_boldi.emit(self)
	var tween := create_tween()
	tween.tween_property(model_root, "rotation:z", deg_to_rad(88.0), 0.42).set_trans(Tween.TRANS_QUAD)
	tween.parallel().tween_property(model_root, "position:y", 0.18, 0.42)
	tween.tween_interval(1.6)
	tween.tween_callback(queue_free)

func _material(r: Color, roughness := 0.82) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = r
	mat.roughness = roughness
	return mat

func _quti(parent: Node3D, nom: String, p: Vector3, hajm: Vector3, mat: Material) -> MeshInstance3D:
	var n := MeshInstance3D.new()
	n.name = nom
	var mesh := BoxMesh.new()
	mesh.size = hajm
	n.mesh = mesh
	n.position = p
	n.material_override = mat
	n.visibility_range_end = 48.0
	parent.add_child(n)
	return n

func _sfera(parent: Node3D, nom: String, p: Vector3, masshtab: Vector3, mat: Material) -> MeshInstance3D:
	var n := MeshInstance3D.new()
	n.name = nom
	var mesh := SphereMesh.new()
	mesh.radius = 0.5
	mesh.height = 1.0
	mesh.radial_segments = 12
	mesh.rings = 6
	n.mesh = mesh
	n.position = p
	n.scale = masshtab
	n.material_override = mat
	n.visibility_range_end = 48.0
	parent.add_child(n)
	return n

func _kapsula(parent: Node3D, nom: String, p: Vector3, radius: float, balandlik: float, mat: Material) -> MeshInstance3D:
	var n := MeshInstance3D.new()
	n.name = nom
	var mesh := CapsuleMesh.new()
	mesh.radius = radius
	mesh.height = balandlik
	mesh.radial_segments = 12
	mesh.rings = 4
	n.mesh = mesh
	n.position = p
	n.material_override = mat
	n.visibility_range_end = 48.0
	parent.add_child(n)
	return n
