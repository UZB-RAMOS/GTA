extends Node3D

signal rejim_ozgardi(rejim)

const REJIMLAR := ["tiniq", "yengil_yomgir", "kuchli_yomgir", "tuman", "bulutli"]

var muhit: Environment
var oyinchi: Node3D
var yomgir: GPUParticles3D
var joriy_rejim := "tiniq"
var sifat := 1

func sozla(yangi_muhit: Environment, yangi_oyinchi: Node3D) -> void:
	muhit = yangi_muhit
	oyinchi = yangi_oyinchi
	_yomgir_yarat()
	rejimni_qoy(joriy_rejim)

func _process(_delta: float) -> void:
	if is_instance_valid(oyinchi) and is_instance_valid(yomgir):
		yomgir.global_position = oyinchi.global_position + Vector3.UP * 12.0

func _yomgir_yarat() -> void:
	yomgir = GPUParticles3D.new()
	yomgir.name = "MahalliyYomgir"
	yomgir.amount = 280
	yomgir.lifetime = 1.25
	yomgir.randomness = 0.28
	yomgir.visibility_aabb = AABB(Vector3(-22, -15, -22), Vector3(44, 30, 44))
	yomgir.emitting = false

	var jarayon := ParticleProcessMaterial.new()
	jarayon.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	jarayon.emission_box_extents = Vector3(18.0, 0.5, 18.0)
	jarayon.direction = Vector3(0.08, -1.0, 0.03)
	jarayon.spread = 4.0
	jarayon.initial_velocity_min = 17.0
	jarayon.initial_velocity_max = 23.0
	jarayon.gravity = Vector3(0.0, -10.0, 0.0)
	yomgir.process_material = jarayon

	var tomchi := BoxMesh.new()
	tomchi.size = Vector3(0.025, 0.62, 0.025)
	var tomchi_mat := StandardMaterial3D.new()
	tomchi_mat.albedo_color = Color(0.60, 0.78, 1.0, 0.62)
	tomchi_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	tomchi_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	tomchi.material = tomchi_mat
	yomgir.draw_pass_1 = tomchi
	add_child(yomgir)

func rejimni_qoy(rejim: String) -> void:
	if not REJIMLAR.has(rejim):
		rejim = "tiniq"
	joriy_rejim = rejim
	if not is_instance_valid(muhit) or not is_instance_valid(yomgir):
		return
	yomgir.emitting = rejim in ["yengil_yomgir", "kuchli_yomgir"] and sifat > 0
	match rejim:
		"yengil_yomgir":
			yomgir.amount = 180 if sifat == 1 else 300
			muhit.fog_density = 0.0072
			muhit.background_color = Color("050b16")
			muhit.ambient_light_energy = 0.28
		"kuchli_yomgir":
			yomgir.amount = 300 if sifat == 1 else 520
			muhit.fog_density = 0.011
			muhit.background_color = Color("030711")
			muhit.ambient_light_energy = 0.25
		"tuman":
			muhit.fog_density = 0.022
			muhit.background_color = Color("101827")
			muhit.ambient_light_energy = 0.34
		"bulutli":
			muhit.fog_density = 0.0085
			muhit.background_color = Color("080b14")
			muhit.ambient_light_energy = 0.27
		_:
			muhit.fog_density = 0.0048
			muhit.background_color = Color("050914")
			muhit.ambient_light_energy = 0.30
	rejim_ozgardi.emit(joriy_rejim)

func sifatni_qoy(yangi_sifat: int) -> void:
	sifat = clampi(yangi_sifat, 0, 2)
	rejimni_qoy(joriy_rejim)

func keyingi_rejim() -> String:
	var indeks := (REJIMLAR.find(joriy_rejim) + 1) % REJIMLAR.size()
	rejimni_qoy(REJIMLAR[indeks])
	return joriy_rejim

func holat_ol() -> Dictionary:
	return {"rejim": joriy_rejim, "sifat": sifat}

func holat_qoy(data: Dictionary) -> void:
	sifat = clampi(int(data.get("sifat", sifat)), 0, 2)
	rejimni_qoy(String(data.get("rejim", "tiniq")))
