extends CharacterBody3D

signal haydovchi_kirdi
signal haydovchi_chiqdi

@export var maksimal_tezlik := 22.0
@export var tezlanish := 13.0
@export var tormoz := 24.0
@export var burilish_tezligi := 1.8
@export var kuzov_rangi := Color("1769aa")

var boshqarilmoqda := false
var haydovchi: CharacterBody3D
var joriy_tezlik := 0.0
var gravitatsiya := 20.0

func _ready() -> void:
	add_to_group("transport")
	collision_layer = 4
	collision_mask = 1 | 4
	_yarat_kuzov()

func _yarat_kuzov() -> void:
	var collider := CollisionShape3D.new()
	var shakl := BoxShape3D.new()
	shakl.size = Vector3(1.9, 1.45, 3.8)
	collider.shape = shakl
	collider.position.y = 0.85
	add_child(collider)

	var pastki := MeshInstance3D.new()
	var pastki_mesh := BoxMesh.new()
	pastki_mesh.size = Vector3(1.9, 1.05, 3.8)
	pastki.mesh = pastki_mesh
	pastki.position.y = 0.75
	pastki.material_override = _material(kuzov_rangi)
	add_child(pastki)

	var yuqori := MeshInstance3D.new()
	var yuqori_mesh := BoxMesh.new()
	yuqori_mesh.size = Vector3(1.65, 0.9, 2.15)
	yuqori.mesh = yuqori_mesh
	yuqori.position = Vector3(0, 1.6, 0.15)
	yuqori.material_override = _material(kuzov_rangi.lightened(0.08))
	add_child(yuqori)

	var oyna_mat := _material(Color("22313f"))
	for z in [-0.98, 0.98]:
		var oyna := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(1.5, 0.55, 0.05)
		oyna.mesh = mesh
		oyna.position = Vector3(0, 1.66, z)
		oyna.material_override = oyna_mat
		add_child(oyna)

	var gildirak_mat := _material(Color("16191d"))
	for x in [-1.0, 1.0]:
		for z in [-1.25, 1.25]:
			var gildirak := MeshInstance3D.new()
			var silindr := CylinderMesh.new()
			silindr.top_radius = 0.36
			silindr.bottom_radius = 0.36
			silindr.height = 0.28
			gildirak.mesh = silindr
			gildirak.rotation.z = PI / 2.0
			gildirak.position = Vector3(x, 0.45, z)
			gildirak.material_override = gildirak_mat
			add_child(gildirak)

func _material(rang: Color) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = rang
	mat.roughness = 0.72
	return mat

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravitatsiya * delta
	else:
		velocity.y = -0.2

	if boshqarilmoqda:
		var gaz := Input.get_axis("orqaga", "oldinga")
		if gaz > 0.0:
			joriy_tezlik = move_toward(joriy_tezlik, maksimal_tezlik, tezlanish * delta)
		elif gaz < 0.0:
			joriy_tezlik = move_toward(joriy_tezlik, -maksimal_tezlik * 0.38, tormoz * delta)
		else:
			joriy_tezlik = move_toward(joriy_tezlik, 0.0, 5.0 * delta)

		var rul := Input.get_axis("ong", "chap")
		if abs(joriy_tezlik) > 0.35:
			var nisbat: float = clampf(abs(joriy_tezlik) / maksimal_tezlik, 0.25, 1.0)
			rotate_y(rul * burilish_tezligi * nisbat * delta * sign(joriy_tezlik))
		if Input.is_action_pressed("qol_tormozi"):
			joriy_tezlik = move_toward(joriy_tezlik, 0.0, tormoz * 1.8 * delta)
	else:
		joriy_tezlik = move_toward(joriy_tezlik, 0.0, 7.0 * delta)

	var old := -global_transform.basis.z
	velocity.x = old.x * joriy_tezlik
	velocity.z = old.z * joriy_tezlik
	move_and_slide()

func kirish(oyinchi: CharacterBody3D) -> void:
	if boshqarilmoqda:
		return
	boshqarilmoqda = true
	haydovchi = oyinchi
	oyinchi.transportga_otir(self)
	haydovchi_kirdi.emit()

func chiqish() -> void:
	if not boshqarilmoqda or not is_instance_valid(haydovchi):
		return
	var chiqish_nuqta := global_position + global_transform.basis.x * 2.2 + Vector3.UP * 0.25
	var eski_haydovchi := haydovchi
	boshqarilmoqda = false
	haydovchi = null
	eski_haydovchi.transportdan_tush(chiqish_nuqta)
	haydovchi_chiqdi.emit()

func tezlik_kmh() -> int:
	return int(abs(joriy_tezlik) * 3.6)

