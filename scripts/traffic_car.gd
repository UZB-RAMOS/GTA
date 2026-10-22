extends CharacterBody3D

@export var rang := Color("c54245")
@export var tezlik := 7.0
var yol: Array[Vector3] = []
var indeks := 0

func _ready() -> void:
	add_to_group("trafik")
	collision_layer = 4
	collision_mask = 1 | 4
	_yarat_model()

func _yarat_model() -> void:
	var collider := CollisionShape3D.new()
	var shakl := BoxShape3D.new()
	shakl.size = Vector3(1.65, 1.1, 3.1)
	collider.shape = shakl
	collider.position.y = 0.65
	add_child(collider)

	var mesh_node := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(1.65, 1.0, 3.1)
	mesh_node.mesh = mesh
	mesh_node.position.y = 0.65
	var mat := StandardMaterial3D.new()
	mat.albedo_color = rang
	mat.roughness = 0.8
	mesh_node.material_override = mat
	add_child(mesh_node)

	var kabina := MeshInstance3D.new()
	var kabina_mesh := BoxMesh.new()
	kabina_mesh.size = Vector3(1.4, 0.65, 1.45)
	kabina.mesh = kabina_mesh
	kabina.position = Vector3(0, 1.42, 0.1)
	var oyna := StandardMaterial3D.new()
	oyna.albedo_color = Color("29445b")
	kabina.material_override = oyna
	add_child(kabina)

func _physics_process(delta: float) -> void:
	if yol.is_empty():
		return
	var maqsad := yol[indeks]
	var farq := maqsad - global_position
	farq.y = 0.0
	if farq.length() < 2.0:
		indeks = (indeks + 1) % yol.size()
		return
	var yonalish := farq.normalized()
	var kerak_burilish := atan2(-yonalish.x, -yonalish.z)
	rotation.y = lerp_angle(rotation.y, kerak_burilish, delta * 2.2)
	velocity = -global_transform.basis.z * tezlik
	velocity.y = -0.4
	move_and_slide()

