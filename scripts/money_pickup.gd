extends Area3D

signal yigildi(miqdor)

@export var miqdor := 2000
var aylanish_tezligi := 2.4

func _ready() -> void:
	name = "PulToplami"
	add_to_group("pul_pickup")
	collision_layer = 0
	collision_mask = 2
	monitoring = true
	body_entered.connect(_tana_kirdi)
	_yarat_model()

func _process(delta: float) -> void:
	rotate_y(delta * aylanish_tezligi)
	position.y += sin(Time.get_ticks_msec() * 0.004 + float(get_instance_id() % 9)) * delta * 0.06

func _tana_kirdi(tana: Node3D) -> void:
	if tana.is_in_group("oyinchi"):
		monitoring = false
		yigildi.emit(miqdor)
		queue_free()

func _yarat_model() -> void:
	var collider := CollisionShape3D.new()
	var shakl := SphereShape3D.new()
	shakl.radius = 0.72
	collider.shape = shakl
	add_child(collider)
	var yashil := _material(Color("47b95e"), 0.55)
	for i in range(3):
		var pul := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(0.64, 0.11, 0.32)
		pul.mesh = mesh
		pul.position = Vector3((i - 1) * 0.12, 0.12 + i * 0.10, 0)
		pul.rotation.y = i * 0.32
		pul.material_override = yashil
		add_child(pul)
	var belgi := Label3D.new()
	belgi.text = "+%s so‘m" % _pul_format(miqdor)
	belgi.font_size = 24
	belgi.outline_size = 5
	belgi.position.y = 1.05
	belgi.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	belgi.modulate = Color("7ff29a")
	add_child(belgi)

func _material(rang: Color, roughness: float) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = rang
	mat.roughness = roughness
	return mat

func _pul_format(qiymat: int) -> String:
	var s := str(qiymat)
	var natija := ""
	while s.length() > 3:
		natija = " " + s.right(3) + natija
		s = s.left(s.length() - 3)
	return s + natija
