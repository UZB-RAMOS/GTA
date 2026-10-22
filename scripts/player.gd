extends CharacterBody3D

signal transportga_kirdi(transport)
signal transportdan_chiqdi

@export var yurish_tezligi := 5.5
@export var yugurish_tezligi := 9.0
@export var sakrash_kuchi := 6.0
@export var sichqon_sezgirligi := 0.0025

var faol := true
var joriy_transport: CharacterBody3D
var gravitatsiya := 18.0
var kamera_pivot: Node3D
var kamera: Camera3D
var tana_mesh: MeshInstance3D
var collider: CollisionShape3D

func _ready() -> void:
	name = "Oyinchi"
	add_to_group("oyinchi")
	collision_layer = 2
	collision_mask = 1 | 4
	_yarat_tana()
	_yarat_kamera()

func _yarat_tana() -> void:
	tana_mesh = MeshInstance3D.new()
	var gavda := BoxMesh.new()
	gavda.size = Vector3(0.70, 0.86, 0.38)
	tana_mesh.mesh = gavda
	tana_mesh.position.y = 1.25
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("2d74da")
	mat.roughness = 0.85
	tana_mesh.material_override = mat
	add_child(tana_mesh)

	var shim := StandardMaterial3D.new()
	shim.albedo_color = Color("263b55")
	shim.roughness = 0.9
	for x in [-0.20, 0.20]:
		var oyoq := MeshInstance3D.new()
		var oyoq_mesh := BoxMesh.new()
		oyoq_mesh.size = Vector3(0.25, 0.72, 0.28)
		oyoq.mesh = oyoq_mesh
		oyoq.position = Vector3(x, 0.47, 0)
		oyoq.material_override = shim
		add_child(oyoq)

	var teri := StandardMaterial3D.new()
	teri.albedo_color = Color("c99064")
	teri.roughness = 0.86
	for x in [-0.47, 0.47]:
		var qol := MeshInstance3D.new()
		var qol_mesh := BoxMesh.new()
		qol_mesh.size = Vector3(0.18, 0.76, 0.20)
		qol.mesh = qol_mesh
		qol.position = Vector3(x, 1.23, 0)
		qol.material_override = mat
		add_child(qol)

		var kaft := MeshInstance3D.new()
		var kaft_mesh := SphereMesh.new()
		kaft_mesh.radius = 0.11
		kaft_mesh.height = 0.22
		kaft.mesh = kaft_mesh
		kaft.position = Vector3(x, 0.80, 0)
		kaft.material_override = teri
		add_child(kaft)

	collider = CollisionShape3D.new()
	var shakl := CapsuleShape3D.new()
	shakl.radius = 0.42
	shakl.height = 1.65
	collider.shape = shakl
	collider.position.y = 0.9
	add_child(collider)

	var bosh := MeshInstance3D.new()
	var sfera := SphereMesh.new()
	sfera.radius = 0.3
	sfera.height = 0.6
	bosh.mesh = sfera
	bosh.position.y = 1.9
	bosh.material_override = teri
	add_child(bosh)

	var soch := MeshInstance3D.new()
	var soch_mesh := SphereMesh.new()
	soch_mesh.radius = 0.31
	soch_mesh.height = 0.28
	soch.mesh = soch_mesh
	soch.position = Vector3(0, 2.08, 0)
	var soch_mat := StandardMaterial3D.new()
	soch_mat.albedo_color = Color("2c211c")
	soch_mat.roughness = 0.95
	soch.material_override = soch_mat
	add_child(soch)

func _yarat_kamera() -> void:
	kamera_pivot = Node3D.new()
	kamera_pivot.name = "KameraPivot"
	kamera_pivot.position = Vector3(0, 1.55, 0)
	add_child(kamera_pivot)

	var prujina := SpringArm3D.new()
	prujina.name = "KameraMasofa"
	prujina.spring_length = 6.5
	prujina.margin = 0.25
	prujina.collision_mask = 1
	kamera_pivot.add_child(prujina)

	kamera = Camera3D.new()
	kamera.name = "AsosiyKamera"
	kamera.current = true
	kamera.fov = 68.0
	prujina.add_child(kamera)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * sichqon_sezgirligi)
		kamera_pivot.rotation.x = clamp(
			kamera_pivot.rotation.x - event.relative.y * sichqon_sezgirligi,
			deg_to_rad(-55.0),
			deg_to_rad(35.0)
		)
	if event.is_action_pressed("ozaro"):
		if faol:
			_transport_qidir()
		elif is_instance_valid(joriy_transport):
			joriy_transport.chiqish()

func _physics_process(delta: float) -> void:
	if not faol:
		if is_instance_valid(joriy_transport):
			global_position = joriy_transport.global_position + Vector3.UP * 0.45
		return

	if not is_on_floor():
		velocity.y -= gravitatsiya * delta
	elif Input.is_action_just_pressed("sakrash"):
		velocity.y = sakrash_kuchi

	var kiritish := Input.get_vector("chap", "ong", "oldinga", "orqaga")
	var yonalish := (transform.basis * Vector3(kiritish.x, 0, kiritish.y)).normalized()
	var tezlik := yugurish_tezligi if Input.is_action_pressed("yugurish") else yurish_tezligi
	if yonalish.length() > 0.01:
		velocity.x = yonalish.x * tezlik
		velocity.z = yonalish.z * tezlik
	else:
		velocity.x = move_toward(velocity.x, 0.0, tezlik * delta * 6.0)
		velocity.z = move_toward(velocity.z, 0.0, tezlik * delta * 6.0)
	move_and_slide()

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
	tana_mesh.visible = false
	for child in get_children():
		if child is MeshInstance3D and child != tana_mesh:
			child.visible = false
	collider.disabled = true
	transportga_kirdi.emit(transport)

func transportdan_tush(chiqish_nuqta: Vector3) -> void:
	global_position = chiqish_nuqta
	faol = true
	joriy_transport = null
	tana_mesh.visible = true
	for child in get_children():
		if child is MeshInstance3D:
			child.visible = true
	set_deferred("collision_layer", 2)
	collider.set_deferred("disabled", false)
	transportdan_chiqdi.emit()

func holat_ol() -> Dictionary:
	return {
		"position": [global_position.x, global_position.y, global_position.z],
		"rotation_y": rotation.y
	}

func holat_qoy(data: Dictionary) -> void:
	if data.has("position"):
		var p: Array = data.position
		global_position = Vector3(float(p[0]), float(p[1]), float(p[2]))
	rotation.y = float(data.get("rotation_y", 0.0))

