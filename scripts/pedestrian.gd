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
var oyoqlar: Array[Node3D] = []
var qollar: Array[Node3D] = []
var qadam_vaqti := 0.0
var kutish_vaqti := 0.0
var jon := 75
var olgan := false
var collider: CollisionShape3D

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
	var shimlar := [Color("26364a"), Color("34383b"), Color("5d493b"), Color("21324e")]
	var sochlar := [Color("201916"), Color("422b21"), Color("17191b"), Color("6b4932")]
	var teri := _material(terilar[rng.randi_range(0, terilar.size() - 1)], 0.9)
	var kiyim := _material(rang, 0.86)
	var shim := _material(shimlar[rng.randi_range(0, shimlar.size() - 1)], 0.92)
	var soch := _material(sochlar[rng.randi_range(0, sochlar.size() - 1)], 0.96)
	var poyabzal := _material(Color("17191c"), 0.78)

	_quti(model_root, "Bel", Vector3(0, 0.82, 0), Vector3(0.43, 0.27, 0.29), shim)
	_quti(model_root, "Gavda", Vector3(0, 1.17, 0), Vector3(0.58, 0.58, 0.34), kiyim)
	_kapsula(model_root, "Boyin", Vector3(0, 1.52, 0), 0.085, 0.22, teri)
	_sfera(model_root, "Bosh", Vector3(0, 1.73, -0.01), Vector3(0.47, 0.55, 0.46), teri)
	_sfera(model_root, "Soch", Vector3(0, 1.90, 0.01), Vector3(0.49, 0.24, 0.47), soch)
	for x in [-0.085, 0.085]:
		_sfera(model_root, "Koz", Vector3(x, 1.76, -0.235), Vector3(0.035, 0.032, 0.02), _material(Color("1d252a"), 0.4))
	_quti(model_root, "Ogiz", Vector3(0, 1.63, -0.237), Vector3(0.10, 0.018, 0.015), _material(Color("79433d")))

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
	if olgan:
		return
	if kutish_vaqti > 0.0:
		kutish_vaqti -= delta
		velocity = Vector3.ZERO
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
	_animatsiya(delta, true)

func _animatsiya(delta: float, yurmoqda: bool) -> void:
	if yurmoqda:
		qadam_vaqti += delta * (6.0 + tezlik)
	var qadam := sin(qadam_vaqti) * 0.55 if yurmoqda else 0.0
	for i in range(oyoqqlar_soni()):
		var belgi := -1.0 if i == 0 else 1.0
		oyoqlar[i].rotation.x = lerp_angle(oyoqlar[i].rotation.x, qadam * belgi, delta * 10.0)
		qollar[i].rotation.x = lerp_angle(qollar[i].rotation.x, -qadam * belgi * 0.7, delta * 10.0)
	model_root.position.y = abs(sin(qadam_vaqti * 2.0)) * 0.025 if yurmoqda else lerpf(model_root.position.y, 0.0, delta * 5.0)

func oyoqqlar_soni() -> int:
	return mini(oyoqlar.size(), qollar.size())

func _yangi_maqsad() -> void:
	maqsad = markaz + Vector3(rng.randf_range(-radius, radius), 0, rng.randf_range(-radius, radius))

func zarar_ol(miqdor: int, _manba = null) -> void:
	if olgan or miqdor <= 0:
		return
	jon -= miqdor
	model_root.rotation.z = deg_to_rad(rng.randf_range(-8.0, 8.0))
	if jon <= 0:
		_halok_bolish()

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
