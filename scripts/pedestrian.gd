extends CharacterBody3D

@export var rang := Color("d7a93b")
@export var markaz := Vector3.ZERO
@export var radius := 8.0
var maqsad := Vector3.ZERO
var tezlik := 1.65
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	add_to_group("piyoda")
	collision_layer = 8
	collision_mask = 1
	rng.seed = hash(name)
	_yarat_model()
	_yangi_maqsad()

func _yarat_model() -> void:
	var collider := CollisionShape3D.new()
	var shakl := CapsuleShape3D.new()
	shakl.radius = 0.3
	shakl.height = 1.4
	collider.shape = shakl
	collider.position.y = 0.75
	add_child(collider)

	var mesh_node := MeshInstance3D.new()
	var mesh := CapsuleMesh.new()
	mesh.radius = 0.3
	mesh.height = 1.4
	mesh_node.mesh = mesh
	mesh_node.position.y = 0.75
	var mat := StandardMaterial3D.new()
	mat.albedo_color = rang
	mesh_node.material_override = mat
	add_child(mesh_node)

	var bosh := MeshInstance3D.new()
	var bosh_mesh := SphereMesh.new()
	bosh_mesh.radius = 0.23
	bosh_mesh.height = 0.46
	bosh.mesh = bosh_mesh
	bosh.position.y = 1.58
	var teri := StandardMaterial3D.new()
	teri.albedo_color = Color("bc8056")
	bosh.material_override = teri
	add_child(bosh)

func _physics_process(delta: float) -> void:
	var farq := maqsad - global_position
	farq.y = 0.0
	if farq.length() < 0.8:
		_yangi_maqsad()
		return
	var yonalish := farq.normalized()
	rotation.y = lerp_angle(rotation.y, atan2(-yonalish.x, -yonalish.z), delta * 4.0)
	velocity = yonalish * tezlik
	velocity.y = -0.5
	move_and_slide()

func _yangi_maqsad() -> void:
	maqsad = markaz + Vector3(rng.randf_range(-radius, radius), 0, rng.randf_range(-radius, radius))

