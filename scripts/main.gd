extends Node3D

const PlayerScript = preload("res://scripts/player.gd")
const VehicleScript = preload("res://scripts/vehicle.gd")
const TrafficScript = preload("res://scripts/traffic_car.gd")
const PedestrianScript = preload("res://scripts/pedestrian.gd")
const TrafficLightScript = preload("res://scripts/traffic_light.gd")
const MinimapScript = preload("res://scripts/minimap.gd")
const StoreScript = preload("res://scripts/store.gd")
const MoneyPickupScript = preload("res://scripts/money_pickup.gd")

const SAVE_PATH := "user://toshkent_sarguzashti_save.json"
const DUNYO_CHEGARASI := 104.0
const DUNYO_HAJMI := 210.0
const CHUNK_HAJMI := 70.0
const YOL_KOORDINATALARI := [-70.0, -35.0, 0.0, 35.0, 70.0]
const YOL_YARIM_KENGLIGI := 5.75
const TRANSPORT_YER_SATHI := -0.10

var oyinchi: CharacterBody3D
var topshiriq_transporti: CharacterBody3D
var belgi: Node3D
var belgi_mesh: MeshInstance3D
var belgi_yozuvi: Label3D
var topshiriq: Dictionary = {}
var bosqich := 0
var pul := 0
var sogliq := 100
var zirh := 0
var hud_yozuvi: Label
var topshiriq_yozuvi: Label
var tezlik_yozuvi: Label
var yordam_yozuvi: Label
var bildirishnoma: Label
var pauza_qatlami: ColorRect
var asosiy_menyu: ColorRect
var davom_tugmasi: Button
var minimap: Control
var bildirishnoma_vaqti := 0.0
var preview_kadr := 0
var inventar_qatlami: ColorRect
var inventar_matni: Label
var dokon_qatlami: ColorRect
var dokon_sarlavhasi: Label
var dokon_mahsulotlari: VBoxContainer
var joriy_dokon: Area3D
var preview_rejimi := false
var ishlash_testi := false
var ishlash_test_kadri := 0
var ishlash_test_boshlanishi := 0
var ishlash_test_process_jami := 0.0
var ishlash_test_physics_jami := 0.0
var ishlash_test_fps_jami := 0.0
var tizim_yangilash_vaqti := 0.0
var yoritish_yangilash_vaqti := 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("oyin_tizimi")
	Engine.max_fps = 60
	_kiritishlarni_sozla()
	_muhit_yarat()
	_shahar_yarat()
	_dokonlar_yarat()
	_oyinchi_yarat()
	_transportlar_yarat()
	_piyodalar_yarat()
	_topshiriq_yukla()
	_belgi_yarat()
	_hud_yarat()
	_topshiriq_bosqichini_qoy(0)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	var argumentlar := OS.get_cmdline_user_args()
	preview_rejimi = argumentlar.has("--capture-preview") or argumentlar.has("--capture-vehicle") or argumentlar.has("--capture-menu") or argumentlar.has("--capture-store")
	ishlash_testi = argumentlar.has("--performance-test")
	if argumentlar.has("--capture-preview"):
		_yordamchi_preview_holat()
	elif argumentlar.has("--capture-vehicle"):
		_yordamchi_transport_preview_holat()
	elif argumentlar.has("--capture-store"):
		pul = 75000
		dokon_och(get_tree().get_first_node_in_group("dokon"))
	elif argumentlar.has("--capture-menu"):
		_asosiy_menyuni_och()
	elif argumentlar.has("--self-test"):
		_self_test.call_deferred()
	elif ishlash_testi:
		ishlash_test_boshlanishi = Time.get_ticks_msec()
	else:
		_asosiy_menyuni_och()

func _kiritishlarni_sozla() -> void:
	_action_key("oldinga", KEY_W)
	_action_key("oldinga", KEY_UP)
	_action_key("orqaga", KEY_S)
	_action_key("orqaga", KEY_DOWN)
	_action_key("chap", KEY_A)
	_action_key("chap", KEY_LEFT)
	_action_key("ong", KEY_D)
	_action_key("ong", KEY_RIGHT)
	_action_key("sakrash", KEY_SPACE)
	_action_key("yugurish", KEY_SHIFT)
	_action_key("otirish", KEY_C)
	_action_key("otirish", KEY_CTRL)
	_action_key("ozaro", KEY_E)
	_action_key("qol_tormozi", KEY_SPACE)
	_action_key("pauza", KEY_ESCAPE)
	_action_key("saqlash", KEY_F5)
	_action_key("yuklash", KEY_F9)
	_action_key("inventar", KEY_I)
	_action_key("qurol_1", KEY_1)
	_action_key("qurol_2", KEY_2)
	_action_key("qurol_3", KEY_3)
	_action_mouse("hujum", MOUSE_BUTTON_LEFT)

func _action_key(action: StringName, tugma: Key) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	var event := InputEventKey.new()
	event.physical_keycode = tugma
	for mavjud in InputMap.action_get_events(action):
		if mavjud is InputEventKey and mavjud.physical_keycode == tugma:
			return
	InputMap.action_add_event(action, event)

func _action_mouse(action: StringName, tugma: MouseButton) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	var event := InputEventMouseButton.new()
	event.button_index = tugma
	for mavjud in InputMap.action_get_events(action):
		if mavjud is InputEventMouseButton and mavjud.button_index == tugma:
			return
	InputMap.action_add_event(action, event)

func _muhit_yarat() -> void:
	var world_env := WorldEnvironment.new()
	world_env.name = "DoimiyTungiMuhit"
	world_env.add_to_group("tungi_muhit")
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("050914")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("17243d")
	env.ambient_light_energy = 0.30
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	# Compatibility rendererda glow katta full-screen xarajat qiladi; emissive chiroqlar o‘zi qoladi.
	env.glow_enabled = false
	env.fog_enabled = true
	env.fog_light_color = Color("121c31")
	env.fog_density = 0.0048
	world_env.environment = env
	add_child(world_env)

	var quyosh := DirectionalLight3D.new()
	quyosh.name = "OyNuri"
	quyosh.rotation_degrees = Vector3(-48, -28, 0)
	quyosh.light_color = Color("9eb7e8")
	quyosh.light_energy = 0.30
	# Minglab procedural detallarda dinamik oy soyasi past quvvatli GPU’da asosiy qotish manbai edi.
	quyosh.shadow_enabled = false
	add_child(quyosh)

func _shahar_yarat() -> void:
	var shahar := Node3D.new()
	shahar.name = "Shahar"
	shahar.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(shahar)
	_chunk_tuzilmasi_yarat(shahar)

	_statik_quti(shahar, "Yer", Vector3(0, -0.3, 0), Vector3(DUNYO_HAJMI, 0.6, DUNYO_HAJMI), Color("26392c"))

	var asfalt := Color("101820")
	for x in YOL_KOORDINATALARI:
		_vizual_quti(shahar, Vector3(x, 0.025, 0), Vector3(11.5, 0.05, DUNYO_HAJMI - 2.0), asfalt)
		_yol_chiziqlari(shahar, true, x)
	for z in YOL_KOORDINATALARI:
		_vizual_quti(shahar, Vector3(0, 0.035, z), Vector3(DUNYO_HAJMI - 2.0, 0.06, 11.5), asfalt)
		_yol_chiziqlari(shahar, false, z)

	var trotuar := Color("50545a")
	for yol in YOL_KOORDINATALARI:
		for taraf in [-6.8, 6.8]:
			_vizual_quti(shahar, Vector3(yol + taraf, 0.10, 0), Vector3(1.8, 0.2, DUNYO_HAJMI - 2.0), trotuar)
			_vizual_quti(shahar, Vector3(0, 0.105, yol + taraf), Vector3(DUNYO_HAJMI - 2.0, 0.21, 1.8), trotuar)

	var rng := RandomNumberGenerator.new()
	rng.seed = 20261021
	var markazlar := [-87.5, -52.5, -17.5, 17.5, 52.5, 87.5]
	var ranglar := [Color("5e533e"), Color("65453a"), Color("405966"), Color("58564f"), Color("405642")]
	var bino_id := 0
	for x in markazlar:
		for z in markazlar:
			var blok := Vector2(x, z)
			if blok.distance_to(Vector2(-20, -18)) < 12.0 or blok.distance_to(Vector2(18, -18)) < 12.0 or blok.distance_to(Vector2(18, 18)) < 12.0 or blok.distance_to(Vector2(-52, 53)) < 12.0 or blok.distance_to(Vector2(54, -52)) < 12.0:
				continue
			var balandlik := rng.randf_range(5.0, 15.0)
			var hajm := Vector3(rng.randf_range(7.0, 10.5), balandlik, rng.randf_range(7.0, 10.5))
			var p := Vector3(x + rng.randf_range(-1.3, 1.3), balandlik * 0.5, z + rng.randf_range(-1.3, 1.3))
			var bino := _statik_quti(shahar, "Bino_%02d" % bino_id, p, hajm, ranglar[bino_id % ranglar.size()])
			_bino_bezagi(bino, hajm)
			bino_id += 1

	_bozor_yarat(shahar)
	_mahalla_markazi_yarat(shahar)
	_daraxtlar_yarat(shahar)
	_piyodalar_yolaklari_yarat(shahar)
	_kocha_jihozlari_yarat(shahar)
	_svetoforlar_yarat(shahar)
	_chegara_yarat(shahar)
	_korsatkich_yarat(shahar, Vector3(-12.0, 3.2, -18), "ESKI SHAHAR", Color("126aa0"))
	_korsatkich_yarat(shahar, Vector3(12.0, 3.2, 23), "YANGI MAHALLA", Color("2c8b57"))

func _yol_chiziqlari(parent: Node3D, vertikal: bool, koordinata: float) -> void:
	var joylar: Array[Vector3] = []
	for i in range(-20, 21):
		var siljish := float(i) * 5.0
		var p := Vector3(koordinata, 0.075, siljish) if vertikal else Vector3(siljish, 0.078, koordinata)
		joylar.append(p)
	var hajm := Vector3(0.13, 0.025, 2.6) if vertikal else Vector3(2.6, 0.025, 0.13)
	_quti_multimesh(parent, "YolChiziqlari", hajm, joylar, Color("b79838"), 118.0)

func _chunk_tuzilmasi_yarat(parent: Node3D) -> void:
	for x in [-CHUNK_HAJMI, 0.0, CHUNK_HAJMI]:
		for z in [-CHUNK_HAJMI, 0.0, CHUNK_HAJMI]:
			var chunk := Node3D.new()
			chunk.name = "Chunk_%d_%d" % [int(x / CHUNK_HAJMI), int(z / CHUNK_HAJMI)]
			chunk.position = Vector3(x, 0, z)
			chunk.set_meta("hajm", Vector2(CHUNK_HAJMI, CHUNK_HAJMI))
			chunk.add_to_group("dunyo_chunki")
			parent.add_child(chunk)

func _bino_bezagi(bino: StaticBody3D, hajm: Vector3) -> void:
	var tom_rangi := Color("422821")
	var yoniq_oyna := _emissive_material(Color("ffd47b"), 1.55)
	var xira_oyna := _material(Color("102431"), 0.34)
	_vizual_quti(bino, Vector3(0, hajm.y * 0.5 + 0.16, 0), Vector3(hajm.x + 0.25, 0.32, hajm.z + 0.25), tom_rangi)
	var qavatlar := maxi(1, int(hajm.y / 3.0))
	for qavat in range(qavatlar):
		var y := -hajm.y * 0.5 + 1.65 + qavat * 2.55
		var oyna_mat: Material = yoniq_oyna if qavat % 3 != 1 else xira_oyna
		for taraf in [-1.0, 1.0]:
			for x in [-hajm.x * 0.27, hajm.x * 0.27]:
				_vizual_quti_material(bino, Vector3(x, y, taraf * (hajm.z * 0.5 + 0.035)), Vector3(1.18, 1.16, 0.065), oyna_mat)
			for z in [-hajm.z * 0.25, hajm.z * 0.25]:
				_vizual_quti_material(bino, Vector3(taraf * (hajm.x * 0.5 + 0.035), y, z), Vector3(0.065, 1.16, 1.10), oyna_mat)
	# Kirish eshigi, soyabon, balkon va tomdagi texnik blok binoni yashaladigan qiladi.
	_vizual_quti(bino, Vector3(0, -hajm.y * 0.5 + 1.05, -hajm.z * 0.5 - 0.045), Vector3(1.25, 2.10, 0.09), Color("6a4935"))
	_vizual_quti(bino, Vector3(0, -hajm.y * 0.5 + 2.23, -hajm.z * 0.5 - 0.40), Vector3(1.75, 0.16, 0.80), tom_rangi)
	if qavatlar > 2:
		for qavat in range(1, qavatlar, 2):
			var y := -hajm.y * 0.5 + 1.25 + qavat * 2.5
			_vizual_quti(bino, Vector3(hajm.x * 0.22, y, -hajm.z * 0.5 - 0.48), Vector3(2.05, 0.13, 0.92), Color("b8b2a4"))
			_vizual_quti(bino, Vector3(hajm.x * 0.22, y + 0.48, -hajm.z * 0.5 - 0.88), Vector3(2.05, 0.82, 0.055), Color("515a60"))
	_vizual_quti(bino, Vector3(hajm.x * 0.24, hajm.y * 0.5 + 0.52, 0), Vector3(1.45, 0.72, 1.25), Color("a8aaa5"))
	# Bino qobig‘i uzoqdan qoladi, deraza va balkonlar esa faqat foydali masofada chiziladi.
	for child in bino.get_children():
		if child is MeshInstance3D and child.get_index() > 1:
			child.visibility_range_end = 64.0

func _bozor_yarat(parent: Node3D) -> void:
	var markaz := Vector3(-20, 0, -18)
	_statik_quti(parent, "Bozor", markaz + Vector3(0, 1.5, 0), Vector3(11, 3, 9), Color("e9b94f"))
	_vizual_quti(parent, markaz + Vector3(0, 3.35, 0), Vector3(12, 0.35, 10), Color("2e9c75"))
	_korsatkich_yarat(parent, markaz + Vector3(0, 4.4, 4.7), "MAHALLA BOZORI", Color("197052"))
	for x in [-4.0, -1.35, 1.35, 4.0]:
		_vizual_quti(parent, markaz + Vector3(x, 1.45, 4.53), Vector3(1.8, 1.25, 0.08), Color("244d68"))

func _mahalla_markazi_yarat(parent: Node3D) -> void:
	var markaz := Node3D.new()
	markaz.name = "MahallaMarkazi"
	markaz.position = Vector3(18, 0, 18)
	markaz.add_to_group("yol_chetidagi_obyekt")
	parent.add_child(markaz)
	_vizual_quti(markaz, Vector3(0, 0.12, 0), Vector3(9, 0.24, 9), Color("d9c39c"))
	var favvora := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = 2.2
	mesh.bottom_radius = 2.2
	mesh.height = 0.55
	mesh.radial_segments = 18
	mesh.rings = 1
	favvora.mesh = mesh
	favvora.position = Vector3(0, 0.32, 0)
	favvora.material_override = _material(Color("67b9d1"), 0.25)
	markaz.add_child(favvora)
	_korsatkich_yarat(markaz, Vector3(0, 3.1, -4.2), "MAHALLA MARKAZI", Color("805d35"))

func _daraxtlar_yarat(parent: Node3D) -> void:
	var joylar := [
		Vector3(-26, 0, -26), Vector3(-10, 0, -25), Vector3(10, 0, -25), Vector3(25, 0, -25),
		Vector3(-25, 0, -10), Vector3(25, 0, -10), Vector3(-25, 0, 10), Vector3(25, 0, 10),
		Vector3(-25, 0, 25), Vector3(-10, 0, 25), Vector3(10, 0, 25), Vector3(25, 0, 25),
		Vector3(-91, 0, -58), Vector3(-82, 0, 54), Vector3(-56, 0, 88), Vector3(-18, 0, 88),
		Vector3(18, 0, -88), Vector3(52, 0, 86), Vector3(88, 0, 54), Vector3(88, 0, -19),
		Vector3(55, 0, -88), Vector3(-88, 0, 18), Vector3(-54, 0, -86), Vector3(86, 0, 87)
	]
	for p in joylar:
		var daraxt := Node3D.new()
		daraxt.name = "YolChetidagiDaraxt"
		daraxt.position = p
		daraxt.add_to_group("yol_chetidagi_obyekt")
		parent.add_child(daraxt)
		var tana := MeshInstance3D.new()
		var tana_mesh := CylinderMesh.new()
		tana_mesh.top_radius = 0.18
		tana_mesh.bottom_radius = 0.25
		tana_mesh.height = 2.8
		tana_mesh.radial_segments = 12
		tana_mesh.rings = 1
		tana.mesh = tana_mesh
		tana.position.y = 1.4
		tana.material_override = _material(Color("79543b"))
		daraxt.add_child(tana)
		var barg := MeshInstance3D.new()
		var barg_mesh := SphereMesh.new()
		barg_mesh.radius = 1.35
		barg_mesh.height = 2.4
		barg_mesh.radial_segments = 12
		barg_mesh.rings = 7
		barg.mesh = barg_mesh
		barg.position.y = 3.25
		barg.material_override = _material(Color("438b4e"))
		daraxt.add_child(barg)

func _piyodalar_yolaklari_yarat(parent: Node3D) -> void:
	var oq := Color("b8b7b1")
	var gorizontal_joylar: Array[Vector3] = []
	var vertikal_joylar: Array[Vector3] = []
	for x in YOL_KOORDINATALARI:
		for z in YOL_KOORDINATALARI:
			for i in range(-4, 5):
				gorizontal_joylar.append(Vector3(x + i * 0.88, 0.085, z - 7.0))
				vertikal_joylar.append(Vector3(x - 7.0, 0.087, z + i * 0.88))
	_quti_multimesh(parent, "PiyodaYolagiGorizontal", Vector3(0.52, 0.025, 3.0), gorizontal_joylar, oq, 112.0)
	_quti_multimesh(parent, "PiyodaYolagiVertikal", Vector3(3.0, 0.025, 0.52), vertikal_joylar, oq, 112.0)

func _kocha_jihozlari_yarat(parent: Node3D) -> void:
	var metall := _material(Color("384044"), 0.55)
	var chiroq_mat := _material(Color("fff0b3"), 0.22)
	chiroq_mat.emission_enabled = true
	chiroq_mat.emission = Color("fff0b3")
	chiroq_mat.emission_energy_multiplier = 1.15
	var chiroq_joylari := [
		Vector3(-28.1, 0, -50), Vector3(-41.9, 0, -24), Vector3(-28.1, 0, 18), Vector3(-41.9, 0, 50),
		Vector3(41.9, 0, -50), Vector3(28.1, 0, -24), Vector3(41.9, 0, 18), Vector3(28.1, 0, 50),
		Vector3(-50, 0, -28.1), Vector3(-22, 0, -41.9), Vector3(22, 0, -28.1), Vector3(50, 0, -41.9),
		Vector3(-50, 0, 41.9), Vector3(-22, 0, 28.1), Vector3(22, 0, 41.9), Vector3(50, 0, 28.1),
		Vector3(-77, 0, -88), Vector3(-42, 0, -88), Vector3(42, 0, -88), Vector3(77, 0, -88),
		Vector3(-77, 0, 88), Vector3(-42, 0, 88), Vector3(42, 0, 88), Vector3(77, 0, 88),
		Vector3(-88, 0, -77), Vector3(-88, 0, 77), Vector3(88, 0, -77), Vector3(88, 0, 77),
		Vector3(-7, 0, -18), Vector3(7, 0, -18), Vector3(-7, 0, 18), Vector3(7, 0, 18),
		Vector3(-63, 0, -7), Vector3(-63, 0, 7), Vector3(63, 0, -7), Vector3(63, 0, 7),
		Vector3(-7, 0, -63), Vector3(7, 0, -63), Vector3(-7, 0, 63), Vector3(7, 0, 63)
	]
	for p in chiroq_joylari:
		var ustun := Node3D.new()
		ustun.name = "KochaChirogi"
		ustun.position = p
		ustun.add_to_group("yol_chetidagi_obyekt")
		parent.add_child(ustun)
		_vizual_silindr(ustun, Vector3(0, 2.6, 0), 0.075, 5.2, metall)
		_vizual_quti(ustun, Vector3(0.38, 5.05, 0), Vector3(0.82, 0.08, 0.08), Color("384044"))
		_vizual_sfera(ustun, Vector3(0.77, 5.0, 0), Vector3(0.30, 0.18, 0.30), chiroq_mat)
		var yoruglik := OmniLight3D.new()
		yoruglik.name = "KochaYorugligi"
		yoruglik.position = Vector3(0.77, 4.78, 0)
		yoruglik.light_color = Color("ffd99a")
		yoruglik.light_energy = 2.8
		yoruglik.omni_range = 15.0
		yoruglik.omni_attenuation = 1.35
		yoruglik.shadow_enabled = false
		yoruglik.distance_fade_enabled = true
		yoruglik.distance_fade_begin = 27.0
		yoruglik.distance_fade_length = 15.0
		yoruglik.add_to_group("shahar_chirogi")
		ustun.add_child(yoruglik)

	# Bekatlar, o‘rindiqlar, axlat qutilari va yo‘l belgilari.
	for p in [Vector3(-8.4, 0, -25), Vector3(8.4, 0, 23)]:
		var bekat := Node3D.new()
		bekat.name = "AvtobusBekati"
		bekat.position = p
		bekat.add_to_group("yol_chetidagi_obyekt")
		parent.add_child(bekat)
		_vizual_quti(bekat, Vector3(0, 1.45, 0), Vector3(3.8, 0.12, 1.55), Color("227eaa"))
		for x in [-1.75, 1.75]:
			_vizual_quti(bekat, Vector3(x, 0.75, 0.62), Vector3(0.10, 1.50, 0.10), Color("4c555b"))
		_vizual_quti(bekat, Vector3(0, 0.58, 0.48), Vector3(2.75, 0.16, 0.55), Color("8f603c"))
		_vizual_quti(bekat, Vector3(0, 0.98, 0.72), Vector3(2.75, 0.70, 0.10), Color("6f4b32"))
		var yozuv := Label3D.new()
		yozuv.text = "AVTOBUS BEKATI"
		yozuv.font_size = 26
		yozuv.outline_size = 5
		yozuv.position = Vector3(0, 1.6, -0.05)
		bekat.add_child(yozuv)
	for p in [Vector3(-28.0, 0, -17), Vector3(28.0, 0, 13), Vector3(-15, 0, 28.0), Vector3(18, 0, -28.0)]:
		var jihoz := Node3D.new()
		jihoz.name = "YolChetidagiOrindiq"
		jihoz.position = p
		jihoz.add_to_group("yol_chetidagi_obyekt")
		parent.add_child(jihoz)
		_vizual_quti(jihoz, Vector3(0, 0.48, 0), Vector3(1.85, 0.16, 0.48), Color("98633d"))
		_vizual_quti(jihoz, Vector3(0, 0.86, 0.20), Vector3(1.85, 0.58, 0.12), Color("7b4e33"))
		for x in [-0.72, 0.72]:
			_vizual_quti(jihoz, Vector3(x, 0.23, 0), Vector3(0.10, 0.45, 0.38), Color("343b3e"))
		_vizual_silindr(jihoz, Vector3(1.25, 0.42, 0), 0.27, 0.72, _material(Color("376c58")))

func _svetoforlar_yarat(parent: Node3D) -> void:
	for x in YOL_KOORDINATALARI:
		for z in YOL_KOORDINATALARI:
			var sozlamalar := [
				[Vector3(x - 6.7, 0, z - 6.7), 0.0, true],
				[Vector3(x + 6.7, 0, z + 6.7), PI, true],
				[Vector3(x + 6.7, 0, z - 6.7), -PI / 2.0, false],
				[Vector3(x - 6.7, 0, z + 6.7), PI / 2.0, false]
			]
			for sozlama in sozlamalar:
				var svetofor := TrafficLightScript.new()
				svetofor.name = "Svetofor"
				svetofor.position = sozlama[0]
				svetofor.rotation.y = sozlama[1]
				svetofor.vertikal_yol = sozlama[2]
				parent.add_child(svetofor)

func _chegara_yarat(parent: Node3D) -> void:
	var devorlar := [
		[Vector3(DUNYO_CHEGARASI, 5.0, 0), Vector3(1.0, 10.0, DUNYO_HAJMI)],
		[Vector3(-DUNYO_CHEGARASI, 5.0, 0), Vector3(1.0, 10.0, DUNYO_HAJMI)],
		[Vector3(0, 5.0, DUNYO_CHEGARASI), Vector3(DUNYO_HAJMI, 10.0, 1.0)],
		[Vector3(0, 5.0, -DUNYO_CHEGARASI), Vector3(DUNYO_HAJMI, 10.0, 1.0)]
	]
	for i in range(devorlar.size()):
		var body := StaticBody3D.new()
		body.name = "KorinmasChegara_%d" % i
		body.add_to_group("dunyo_chegarasi")
		body.position = devorlar[i][0]
		body.collision_layer = 1
		body.collision_mask = 0
		parent.add_child(body)
		var collider := CollisionShape3D.new()
		var shakl := BoxShape3D.new()
		shakl.size = devorlar[i][1]
		collider.shape = shakl
		body.add_child(collider)

func _korsatkich_yarat(parent: Node3D, p: Vector3, matn: String, rang: Color) -> void:
	var label := Label3D.new()
	label.text = matn
	label.font_size = 42
	label.outline_size = 8
	label.modulate = Color.WHITE
	label.outline_modulate = rang.darkened(0.45)
	label.position = p
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	parent.add_child(label)

func _yol_ustidami(p: Vector3, zaxira := 0.0) -> bool:
	for yol in YOL_KOORDINATALARI:
		if absf(p.x - yol) <= YOL_YARIM_KENGLIGI + zaxira:
			return true
		if absf(p.z - yol) <= YOL_YARIM_KENGLIGI + zaxira:
			return true
	return false

func _statik_quti(parent: Node3D, nom: String, p: Vector3, hajm: Vector3, rang: Color) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = nom
	body.position = p
	body.collision_layer = 1
	body.collision_mask = 0
	parent.add_child(body)
	var collider := CollisionShape3D.new()
	var shakl := BoxShape3D.new()
	shakl.size = hajm
	collider.shape = shakl
	body.add_child(collider)
	_vizual_quti(body, Vector3.ZERO, hajm, rang)
	return body

func _vizual_quti(parent: Node3D, p: Vector3, hajm: Vector3, rang: Color) -> MeshInstance3D:
	return _vizual_quti_material(parent, p, hajm, _material(rang))

func _vizual_quti_material(parent: Node3D, p: Vector3, hajm: Vector3, mat: Material) -> MeshInstance3D:
	var mesh_node := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = hajm
	mesh_node.mesh = mesh
	mesh_node.position = p
	mesh_node.material_override = mat
	mesh_node.visibility_range_end = 112.0
	parent.add_child(mesh_node)
	return mesh_node

func _quti_multimesh(parent: Node3D, nom: String, hajm: Vector3, joylar: Array[Vector3], rang: Color, korinish_masofasi: float) -> MultiMeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = hajm
	mesh.material = _material(rang)
	var multimesh := MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.mesh = mesh
	multimesh.instance_count = joylar.size()
	for i in range(joylar.size()):
		multimesh.set_instance_transform(i, Transform3D(Basis.IDENTITY, joylar[i]))
	var natija := MultiMeshInstance3D.new()
	natija.name = nom
	natija.multimesh = multimesh
	natija.visibility_range_end = korinish_masofasi
	parent.add_child(natija)
	return natija

func _vizual_silindr(parent: Node3D, p: Vector3, radius: float, balandlik: float, mat: Material) -> MeshInstance3D:
	var mesh_node := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = balandlik
	mesh.radial_segments = 12
	mesh.rings = 1
	mesh_node.mesh = mesh
	mesh_node.position = p
	mesh_node.material_override = mat
	mesh_node.visibility_range_end = 112.0
	parent.add_child(mesh_node)
	return mesh_node

func _vizual_sfera(parent: Node3D, p: Vector3, masshtab: Vector3, mat: Material) -> MeshInstance3D:
	var mesh_node := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 0.5
	mesh.height = 1.0
	mesh.radial_segments = 12
	mesh.rings = 7
	mesh_node.mesh = mesh
	mesh_node.position = p
	mesh_node.scale = masshtab
	mesh_node.material_override = mat
	mesh_node.visibility_range_end = 112.0
	parent.add_child(mesh_node)
	return mesh_node

func _material(rang: Color, roughness := 0.82) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = rang
	mat.roughness = roughness
	return mat

func _emissive_material(rang: Color, kuch: float) -> StandardMaterial3D:
	var mat := _material(rang, 0.28)
	mat.emission_enabled = true
	mat.emission = rang
	mat.emission_energy_multiplier = kuch
	return mat

func _dokonlar_yarat() -> void:
	var sozlamalar := [
		["Chorsu anjomlari", Vector3(18, 0, -18), Color("267f68"), 0.0],
		["Yangi mahalla marketi", Vector3(-52, 0, 53), Color("2e6f9b"), PI],
		["Toshkent savdo uyi", Vector3(54, 0, -52), Color("a36135"), -PI / 2.0]
	]
	for i in range(sozlamalar.size()):
		var dokon := StoreScript.new()
		dokon.process_mode = Node.PROCESS_MODE_PAUSABLE
		dokon.name = "Dokon_%02d" % i
		dokon.dokon_nomi = sozlamalar[i][0]
		dokon.position = sozlamalar[i][1]
		dokon.dokon_rangi = sozlamalar[i][2]
		dokon.rotation.y = sozlamalar[i][3]
		add_child(dokon)

func _oyinchi_yarat() -> void:
	oyinchi = PlayerScript.new()
	oyinchi.process_mode = Node.PROCESS_MODE_PAUSABLE
	oyinchi.position = Vector3(-7, 0.2, -4)
	add_child(oyinchi)
	oyinchi.zarar_oldi.connect(_oyinchi_zarar_oldi)

func _transportlar_yarat() -> void:
	topshiriq_transporti = VehicleScript.new()
	topshiriq_transporti.process_mode = Node.PROCESS_MODE_PAUSABLE
	topshiriq_transporti.name = "JMJShaharSedani"
	topshiriq_transporti.kuzov_rangi = Color("263f59")
	topshiriq_transporti.position = Vector3(-12, TRANSPORT_YER_SATHI, 2)
	topshiriq_transporti.rotation.y = PI / 2.0
	add_child(topshiriq_transporti)

	var tashqi_yol: Array[Vector3] = [
		Vector3(-70, TRANSPORT_YER_SATHI, -70), Vector3(0, TRANSPORT_YER_SATHI, -70), Vector3(70, TRANSPORT_YER_SATHI, -70), Vector3(70, TRANSPORT_YER_SATHI, 0),
		Vector3(70, TRANSPORT_YER_SATHI, 70), Vector3(0, TRANSPORT_YER_SATHI, 70), Vector3(-70, TRANSPORT_YER_SATHI, 70), Vector3(-70, TRANSPORT_YER_SATHI, 0)
	]
	var ichki_yol: Array[Vector3] = [
		Vector3(-35, TRANSPORT_YER_SATHI, -35), Vector3(0, TRANSPORT_YER_SATHI, -35), Vector3(35, TRANSPORT_YER_SATHI, -35), Vector3(35, TRANSPORT_YER_SATHI, 0),
		Vector3(35, TRANSPORT_YER_SATHI, 35), Vector3(0, TRANSPORT_YER_SATHI, 35), Vector3(-35, TRANSPORT_YER_SATHI, 35), Vector3(-35, TRANSPORT_YER_SATHI, 0)
	]
	var ranglar := [Color("6f2427"), Color("8a6926"), Color("a5a49e"), Color("285c40"), Color("48345f"), Color("824127"), Color("243f65"), Color("20252a"), Color("85837e"), Color("4c171b")]
	for i in range(16):
		var yol: Array[Vector3] = tashqi_yol if i % 2 == 0 else ichki_yol
		var mashina := TrafficScript.new()
		mashina.process_mode = Node.PROCESS_MODE_PAUSABLE
		mashina.name = "Trafik_%02d" % i
		mashina.rang = ranglar[i % ranglar.size()]
		mashina.tezlik = 5.8 + (i % 7) * 0.32
		mashina.yol = yol.duplicate()
		mashina.indeks = i % yol.size()
		mashina.position = yol[i % yol.size()].lerp(yol[(i + 1) % yol.size()], 0.16 + 0.09 * (i % 4))
		add_child(mashina)

func _piyodalar_yarat() -> void:
	var ranglar := [Color("75451f"), Color("28466d"), Color("4b6934"), Color("66334f"), Color("716624"), Color("245142"), Color("642b28")]
	var markazlar := [Vector3(-25, 0.1, -25), Vector3(19, 0.1, -20), Vector3(-18, 0.1, 20), Vector3(25, 0.1, 25), Vector3(-28, 0.1, 4), Vector3(18, 0.1, 4), Vector3(3, 0.1, 29), Vector3(-84, 0.1, -53), Vector3(-53, 0.1, 53), Vector3(53, 0.1, -53), Vector3(84, 0.1, 52)]
	for i in range(44):
		var piyoda := PedestrianScript.new()
		piyoda.process_mode = Node.PROCESS_MODE_PAUSABLE
		piyoda.name = "Piyoda_%02d" % i
		piyoda.rang = ranglar[i % ranglar.size()]
		piyoda.markaz = markazlar[i % markazlar.size()]
		piyoda.radius = 6.0 + float(i % 3)
		piyoda.position = piyoda.markaz + Vector3(float((i % 4) - 2) * 1.5, 0, float((i % 3) - 1) * 1.4)
		add_child(piyoda)
		piyoda.pul_tushdi.connect(_pul_pickup_yarat)

func _pul_pickup_yarat(joy: Vector3, miqdor: int) -> void:
	var pickup := MoneyPickupScript.new()
	pickup.process_mode = Node.PROCESS_MODE_PAUSABLE
	pickup.miqdor = miqdor
	pickup.position = joy
	add_child(pickup)
	pickup.yigildi.connect(_pul_yigildi)

func _pul_yigildi(miqdor: int) -> void:
	pul += miqdor
	_xabar("+%s so‘m olindi" % _pul_format(miqdor), 2.5)

func _oyinchi_zarar_oldi(miqdor: int, _manba = null) -> void:
	var qolgan := miqdor
	if zirh > 0:
		var yutilgan := mini(zirh, ceili(miqdor * 0.62))
		zirh -= yutilgan
		qolgan -= yutilgan
	if qolgan > 0:
		sogliq = maxi(0, sogliq - qolgan)
	_xabar("-%d jon  •  Jon: %d  Zirh: %d" % [qolgan, sogliq, zirh], 2.2)
	if sogliq <= 0:
		_oyinchi_qayta_tiril.call_deferred()

func _oyinchi_qayta_tiril() -> void:
	if is_instance_valid(oyinchi.joriy_transport):
		oyinchi.joriy_transport.joriy_tezlik = 0.0
		oyinchi.joriy_transport.chiqish()
	sogliq = 100
	zirh = 0
	var jarima := mini(pul, maxi(1000, int(pul * 0.10)))
	pul -= jarima
	oyinchi.global_position = Vector3(-7, 0.25, -4)
	oyinchi.velocity = Vector3.ZERO
	_xabar("Siz shifoxonada uyg‘ondingiz. Jarima: %s so‘m" % _pul_format(jarima), 5.0)

func _topshiriq_yukla() -> void:
	var matn := FileAccess.get_file_as_string("res://data/mission_01.json")
	var parsed = JSON.parse_string(matn)
	if parsed is Dictionary:
		topshiriq = parsed
	else:
		push_error("Topshiriq JSON yuklanmadi")
		topshiriq = {"title": "Topshiriq", "stages": []}

func _belgi_yarat() -> void:
	belgi = Node3D.new()
	belgi.name = "TopshiriqBelgisi"
	add_child(belgi)
	belgi_mesh = MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = 1.5
	mesh.bottom_radius = 1.5
	mesh.height = 0.18
	mesh.radial_segments = 18
	mesh.rings = 1
	belgi_mesh.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.79, 0.12, 0.72)
	mat.emission_enabled = true
	mat.emission = Color("ffcf32")
	mat.emission_energy_multiplier = 1.7
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	belgi_mesh.material_override = mat
	belgi.add_child(belgi_mesh)

	belgi_yozuvi = Label3D.new()
	belgi_yozuvi.text = "MAQSAD"
	belgi_yozuvi.font_size = 34
	belgi_yozuvi.outline_size = 7
	belgi_yozuvi.position.y = 2.2
	belgi_yozuvi.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	belgi.add_child(belgi_yozuvi)

func _hud_yarat() -> void:
	var canvas := CanvasLayer.new()
	canvas.name = "HUD"
	add_child(canvas)

	var yuqori_panel := ColorRect.new()
	yuqori_panel.position = Vector2(18, 18)
	yuqori_panel.size = Vector2(390, 148)
	yuqori_panel.color = Color(0.025, 0.045, 0.065, 0.82)
	canvas.add_child(yuqori_panel)

	hud_yozuvi = Label.new()
	hud_yozuvi.position = Vector2(36, 30)
	hud_yozuvi.size = Vector2(355, 128)
	hud_yozuvi.add_theme_font_size_override("font_size", 20)
	hud_yozuvi.add_theme_color_override("font_color", Color("f7f1df"))
	canvas.add_child(hud_yozuvi)

	tezlik_yozuvi = Label.new()
	tezlik_yozuvi.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	tezlik_yozuvi.position = Vector2(-255, -92)
	tezlik_yozuvi.size = Vector2(220, 55)
	tezlik_yozuvi.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	tezlik_yozuvi.add_theme_font_size_override("font_size", 30)
	tezlik_yozuvi.add_theme_color_override("font_color", Color("f6d65c"))
	canvas.add_child(tezlik_yozuvi)

	var mission_panel := ColorRect.new()
	mission_panel.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	mission_panel.position = Vector2(-330, -92)
	mission_panel.size = Vector2(660, 62)
	mission_panel.color = Color(0.025, 0.045, 0.065, 0.86)
	canvas.add_child(mission_panel)

	topshiriq_yozuvi = Label.new()
	topshiriq_yozuvi.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	topshiriq_yozuvi.position = Vector2(-310, -82)
	topshiriq_yozuvi.size = Vector2(620, 44)
	topshiriq_yozuvi.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	topshiriq_yozuvi.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	topshiriq_yozuvi.add_theme_font_size_override("font_size", 21)
	topshiriq_yozuvi.add_theme_color_override("font_color", Color("ffdd68"))
	canvas.add_child(topshiriq_yozuvi)

	yordam_yozuvi = Label.new()
	yordam_yozuvi.position = Vector2(20, 176)
	yordam_yozuvi.size = Vector2(870, 70)
	yordam_yozuvi.text = "WASD — harakat  |  Sichqon chap — urish  |  1/2/3 — qurol  |  I — inventar\nE — transport/do‘kon  |  C/Ctrl — o‘tirish  |  Space — sakrash/tormoz  |  F5/F9 — saqlash/yuklash"
	yordam_yozuvi.add_theme_font_size_override("font_size", 16)
	yordam_yozuvi.add_theme_color_override("font_color", Color(1, 1, 1, 0.88))
	canvas.add_child(yordam_yozuvi)

	bildirishnoma = Label.new()
	bildirishnoma.set_anchors_preset(Control.PRESET_CENTER_TOP)
	bildirishnoma.position = Vector2(-230, 35)
	bildirishnoma.size = Vector2(460, 48)
	bildirishnoma.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bildirishnoma.add_theme_font_size_override("font_size", 22)
	bildirishnoma.add_theme_color_override("font_color", Color("8ff0b0"))
	canvas.add_child(bildirishnoma)

	minimap = MinimapScript.new()
	minimap.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	minimap.position = Vector2(-202, 18)
	minimap.size = Vector2(180, 180)
	minimap.oyinchi = oyinchi
	minimap.dunyo_radiusi = DUNYO_CHEGARASI
	canvas.add_child(minimap)

	_inventar_oynasi_yarat(canvas)
	_dokon_oynasi_yarat(canvas)
	_pauza_menyusi_yarat(canvas)
	_asosiy_menyu_yarat(canvas)

func _inventar_oynasi_yarat(canvas: CanvasLayer) -> void:
	inventar_qatlami = ColorRect.new()
	inventar_qatlami.name = "InventarOynasi"
	inventar_qatlami.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	inventar_qatlami.color = Color(0.01, 0.02, 0.03, 0.86)
	inventar_qatlami.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	inventar_qatlami.visible = false
	canvas.add_child(inventar_qatlami)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	inventar_qatlami.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(520, 410)
	center.add_child(panel)
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)
	panel.add_child(vbox)
	var sarlavha := Label.new()
	sarlavha.text = "INVENTAR"
	sarlavha.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sarlavha.add_theme_font_size_override("font_size", 34)
	vbox.add_child(sarlavha)
	inventar_matni = Label.new()
	inventar_matni.custom_minimum_size = Vector2(470, 240)
	inventar_matni.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	inventar_matni.add_theme_font_size_override("font_size", 22)
	vbox.add_child(inventar_matni)
	var yopish := Button.new()
	yopish.text = "Yopish (I yoki Esc)"
	yopish.custom_minimum_size.y = 52
	yopish.pressed.connect(_inventar_yop)
	vbox.add_child(yopish)

func _dokon_oynasi_yarat(canvas: CanvasLayer) -> void:
	dokon_qatlami = ColorRect.new()
	dokon_qatlami.name = "DokonOynasi"
	dokon_qatlami.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dokon_qatlami.color = Color(0.01, 0.025, 0.035, 0.90)
	dokon_qatlami.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	dokon_qatlami.visible = false
	canvas.add_child(dokon_qatlami)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dokon_qatlami.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(650, 540)
	center.add_child(panel)
	dokon_mahsulotlari = VBoxContainer.new()
	dokon_mahsulotlari.add_theme_constant_override("separation", 12)
	panel.add_child(dokon_mahsulotlari)

func dokon_och(dokon: Area3D) -> void:
	if asosiy_menyu.visible or not is_instance_valid(dokon):
		return
	joriy_dokon = dokon
	_dokon_tarkibini_yangila()
	dokon_qatlami.visible = true
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _dokon_tarkibini_yangila() -> void:
	for child in dokon_mahsulotlari.get_children():
		child.queue_free()
	dokon_sarlavhasi = Label.new()
	dokon_sarlavhasi.text = "%s\nPul: %s so‘m" % [joriy_dokon.dokon_nomi.to_upper(), _pul_format(pul)]
	dokon_sarlavhasi.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dokon_sarlavhasi.add_theme_font_size_override("font_size", 30)
	dokon_sarlavhasi.add_theme_color_override("font_color", Color("f6d66c"))
	dokon_mahsulotlari.add_child(dokon_sarlavhasi)
	for mahsulot in joriy_dokon.mahsulotlar:
		var tugma := Button.new()
		var id := String(mahsulot.id)
		var sotib_olingan: bool = id in ["tayoq", "elektroshoker"] and oyinchi.inventar.has(id)
		tugma.text = "%s — %s so‘m  •  %s" % [mahsulot.nom, _pul_format(int(mahsulot.narx)), mahsulot.izoh]
		if sotib_olingan:
			tugma.text += "  [SOTIB OLINGAN]"
			tugma.disabled = true
		tugma.custom_minimum_size.y = 60
		tugma.pressed.connect(_mahsulot_sotib_ol.bind(id))
		dokon_mahsulotlari.add_child(tugma)
	var yopish := Button.new()
	yopish.text = "Do‘konni yopish"
	yopish.custom_minimum_size.y = 54
	yopish.pressed.connect(_dokon_yop)
	dokon_mahsulotlari.add_child(yopish)

func _mahsulot_sotib_ol(id: String) -> void:
	if not is_instance_valid(joriy_dokon):
		return
	var topildi: Dictionary = {}
	for mahsulot in joriy_dokon.mahsulotlar:
		if String(mahsulot.id) == id:
			topildi = mahsulot
			break
	if topildi.is_empty():
		return
	var narx := int(topildi.narx)
	if id in ["tayoq", "elektroshoker"] and oyinchi.inventar.has(id):
		_xabar("Bu qurol inventarda bor", 2.5)
		return
	if id == "dori" and sogliq >= 100:
		_xabar("Jon allaqachon to‘liq", 2.5)
		return
	if id == "zirh" and zirh >= 100:
		_xabar("Zirh allaqachon to‘liq", 2.5)
		return
	if pul < narx:
		_xabar("Pul yetarli emas", 2.5)
		return
	pul -= narx
	match id:
		"dori":
			sogliq = mini(100, sogliq + 40)
		"zirh":
			zirh = mini(100, zirh + 60)
		"tayoq", "elektroshoker":
			oyinchi.inventar_qosh(id)
	var xabar_matni := "%s sotib olindi" % topildi.nom
	if id in ["tayoq", "elektroshoker"]:
		xabar_matni += " va qo‘lga olindi"
	_xabar(xabar_matni, 3.0)
	_dokon_tarkibini_yangila()

func _dokon_yop() -> void:
	dokon_qatlami.visible = false
	joriy_dokon = null
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _inventar_almashtir() -> void:
	if inventar_qatlami.visible:
		_inventar_yop()
		return
	if get_tree().paused or asosiy_menyu.visible:
		return
	_inventar_matn_yangila()
	inventar_qatlami.visible = true
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _inventar_matn_yangila() -> void:
	var satrlar: Array[String] = []
	for id in oyinchi.inventar:
		var sozlama: Dictionary = PlayerScript.QUROLLAR.get(id, {})
		if not sozlama.is_empty():
			satrlar.append("• %s%s" % [sozlama.nom, "  [TANLANGAN]" if id == oyinchi.faol_qurol else ""])
	inventar_matni.text = "Jon: %d/100\nZirh: %d/100\nPul: %s so‘m\n\nQurollar:\n%s\n\n1 — Musht   2 — Metall tayoq   3 — Elektroshoker" % [sogliq, zirh, _pul_format(pul), "\n".join(satrlar)]

func _inventar_yop() -> void:
	inventar_qatlami.visible = false
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _asosiy_menyu_yarat(canvas: CanvasLayer) -> void:
	asosiy_menyu = ColorRect.new()
	asosiy_menyu.name = "AsosiyMenyu"
	asosiy_menyu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	asosiy_menyu.color = Color("183049")
	asosiy_menyu.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	asosiy_menyu.visible = false
	canvas.add_child(asosiy_menyu)

	var bezak := ColorRect.new()
	bezak.set_anchors_preset(Control.PRESET_TOP_LEFT)
	bezak.position = Vector2(0, 0)
	bezak.size = Vector2(420, 720)
	bezak.color = Color("167d67")
	asosiy_menyu.add_child(bezak)

	var chiziq := ColorRect.new()
	chiziq.position = Vector2(420, 0)
	chiziq.size = Vector2(12, 720)
	chiziq.color = Color("f1c84b")
	asosiy_menyu.add_child(chiziq)

	var shahar_nomi := Label.new()
	shahar_nomi.position = Vector2(54, 70)
	shahar_nomi.size = Vector2(330, 220)
	shahar_nomi.text = "TOSHKENT\nSARGUZASHTI"
	shahar_nomi.add_theme_font_size_override("font_size", 44)
	shahar_nomi.add_theme_color_override("font_color", Color("fff7df"))
	bezak.add_child(shahar_nomi)

	var tag := Label.new()
	tag.position = Vector2(58, 250)
	tag.size = Vector2(315, 120)
	tag.text = "Original ochiq-dunyo prototipi\nMahalla • transport • sarguzasht"
	tag.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tag.add_theme_font_size_override("font_size", 19)
	tag.add_theme_color_override("font_color", Color("d6f4e9"))
	bezak.add_child(tag)

	var brend := Label.new()
	brend.name = "JMJGems"
	brend.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	brend.position = Vector2(58, -76)
	brend.size = Vector2(310, 40)
	brend.text = "by JMJ gems"
	brend.add_theme_font_size_override("font_size", 24)
	brend.add_theme_color_override("font_color", Color("f6d66c"))
	bezak.add_child(brend)

	var tashqi := MarginContainer.new()
	tashqi.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	tashqi.add_theme_constant_override("margin_left", 520)
	tashqi.add_theme_constant_override("margin_right", 150)
	tashqi.add_theme_constant_override("margin_top", 115)
	tashqi.add_theme_constant_override("margin_bottom", 95)
	asosiy_menyu.add_child(tashqi)
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 18)
	tashqi.add_child(vbox)
	var sarlavha := Label.new()
	sarlavha.text = "ASOSIY MENYU"
	sarlavha.add_theme_font_size_override("font_size", 34)
	sarlavha.add_theme_color_override("font_color", Color("f6d66c"))
	vbox.add_child(sarlavha)
	var yangi := Button.new()
	yangi.text = "Yangi o‘yin"
	yangi.custom_minimum_size.y = 58
	yangi.pressed.connect(_yangi_oyin)
	vbox.add_child(yangi)
	davom_tugmasi = Button.new()
	davom_tugmasi.text = "Davom etish"
	davom_tugmasi.custom_minimum_size.y = 58
	davom_tugmasi.pressed.connect(_davom_etish)
	vbox.add_child(davom_tugmasi)
	var sozlama := Button.new()
	sozlama.text = "Sozlamalar"
	sozlama.custom_minimum_size.y = 58
	sozlama.pressed.connect(_menyu_sozlamalari)
	vbox.add_child(sozlama)
	var muallif := Button.new()
	muallif.text = "Mualliflar va litsenziyalar"
	muallif.custom_minimum_size.y = 58
	muallif.pressed.connect(_mualliflar)
	vbox.add_child(muallif)
	var chiqish := Button.new()
	chiqish.text = "O‘yindan chiqish"
	chiqish.custom_minimum_size.y = 58
	chiqish.pressed.connect(_oyindan_chiqish)
	vbox.add_child(chiqish)

func _asosiy_menyuni_och() -> void:
	get_tree().paused = true
	asosiy_menyu.visible = true
	pauza_qatlami.visible = false
	davom_tugmasi.disabled = not FileAccess.file_exists(SAVE_PATH)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _yangi_oyin() -> void:
	pul = 0
	sogliq = 100
	zirh = 0
	if is_instance_valid(oyinchi.joriy_transport):
		oyinchi.joriy_transport.chiqish()
	oyinchi.global_position = Vector3(-7, 0.2, -4)
	oyinchi.rotation = Vector3.ZERO
	oyinchi.inventar_qoy(["musht"], "musht")
	topshiriq_transporti.global_position = Vector3(-12, TRANSPORT_YER_SATHI, 2)
	topshiriq_transporti.rotation.y = PI / 2.0
	topshiriq_transporti.joriy_tezlik = 0.0
	topshiriq_transporti.tiklash()
	_topshiriq_bosqichini_qoy(0, false)
	asosiy_menyu.visible = false
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_xabar("Xush kelibsiz! Birinchi topshiriqni boshlang.", 4.0)

func _davom_etish() -> void:
	asosiy_menyu.visible = false
	_yuklash()

func _menyu_sozlamalari() -> void:
	_xabar("Ovoz va grafika sozlamalari Pause menyusida mavjud", 4.0)

func _mualliflar() -> void:
	_xabar("Original kod va procedural grafika • Godot Engine MIT License", 6.0)

func _pauza_menyusi_yarat(canvas: CanvasLayer) -> void:
	pauza_qatlami = ColorRect.new()
	pauza_qatlami.name = "PauzaMenyusi"
	pauza_qatlami.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pauza_qatlami.color = Color(0.01, 0.02, 0.035, 0.87)
	pauza_qatlami.visible = false
	pauza_qatlami.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	canvas.add_child(pauza_qatlami)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pauza_qatlami.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(470, 440)
	center.add_child(panel)
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 15)
	panel.add_child(vbox)
	var sarlavha := Label.new()
	sarlavha.text = "TOSHKENT SARGUZASHTI"
	sarlavha.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sarlavha.add_theme_font_size_override("font_size", 34)
	vbox.add_child(sarlavha)
	var izoh := Label.new()
	izoh.text = "Pauza"
	izoh.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	izoh.add_theme_font_size_override("font_size", 22)
	vbox.add_child(izoh)
	var davom := Button.new()
	davom.text = "Davom etish"
	davom.pressed.connect(_pauzani_yop)
	vbox.add_child(davom)
	var saqla := Button.new()
	saqla.text = "O‘yinni saqlash"
	saqla.pressed.connect(_saqlash)
	vbox.add_child(saqla)
	var yukla := Button.new()
	yukla.text = "Saqlangan o‘yinni yuklash"
	yukla.pressed.connect(_yuklash)
	vbox.add_child(yukla)
	var ovoz_label := Label.new()
	ovoz_label.text = "Umumiy ovoz"
	vbox.add_child(ovoz_label)
	var ovoz := HSlider.new()
	ovoz.min_value = -40.0
	ovoz.max_value = 0.0
	ovoz.value = 0.0
	ovoz.value_changed.connect(_ovoz_ozgardi)
	vbox.add_child(ovoz)
	var sifat := Label.new()
	sifat.text = "Grafika: Compatibility / Windows"
	sifat.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(sifat)
	var chiqish := Button.new()
	chiqish.text = "O‘yindan chiqish"
	chiqish.pressed.connect(_oyindan_chiqish)
	vbox.add_child(chiqish)

func _process(delta: float) -> void:
	if not get_tree().paused and belgi and belgi.visible:
		belgi.rotation.y += delta * 0.8
		belgi_mesh.position.y = 0.18 + sin(Time.get_ticks_msec() * 0.003) * 0.08
	tizim_yangilash_vaqti -= delta
	if tizim_yangilash_vaqti <= 0.0:
		tizim_yangilash_vaqti = 0.10
		if not get_tree().paused:
			_topshiriqni_tekshir()
		_hud_yangila()
	if bildirishnoma_vaqti > 0.0:
		bildirishnoma_vaqti -= delta
		if bildirishnoma_vaqti <= 0.0:
			bildirishnoma.text = ""
	yoritish_yangilash_vaqti -= delta
	if yoritish_yangilash_vaqti <= 0.0:
		yoritish_yangilash_vaqti = 0.30
		_yoritish_lod_yangila()
	if preview_rejimi:
		preview_kadr += 1
		if preview_kadr == 24:
			_preview_saqlash.call_deferred()
	if ishlash_testi:
		_ishlash_testini_yangila()

func _yoritish_lod_yangila() -> void:
	if not is_instance_valid(oyinchi) or not is_instance_valid(oyinchi.kamera):
		return
	var kamera_joyi: Vector3 = oyinchi.kamera.global_position
	for chiroq in get_tree().get_nodes_in_group("shahar_chirogi"):
		chiroq.visible = chiroq.global_position.distance_squared_to(kamera_joyi) < 2304.0
	for fara in get_tree().get_nodes_in_group("avtomobil_farasi"):
		fara.visible = fara.global_position.distance_squared_to(kamera_joyi) < 3600.0

func _ishlash_testini_yangila() -> void:
	ishlash_test_kadri += 1
	if ishlash_test_kadri <= 45:
		return
	ishlash_test_process_jami += Performance.get_monitor(Performance.TIME_PROCESS)
	ishlash_test_physics_jami += Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)
	ishlash_test_fps_jami += Performance.get_monitor(Performance.TIME_FPS)
	if ishlash_test_kadri < 225:
		return
	var namuna_soni := 180.0
	var natija := {
		"orta_fps": snappedf(ishlash_test_fps_jami / namuna_soni, 0.1),
		"process_ms": snappedf(ishlash_test_process_jami * 1000.0 / namuna_soni, 0.01),
		"physics_ms": snappedf(ishlash_test_physics_jami * 1000.0 / namuna_soni, 0.01),
		"draw_call": int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)),
		"obyekt": int(Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME)),
		"primitive": int(Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)),
		"vaqt_ms": Time.get_ticks_msec() - ishlash_test_boshlanishi
	}
	print("PERFORMANCE_TEST: %s" % JSON.stringify(natija))
	get_tree().quit()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("inventar"):
		if not dokon_qatlami.visible and not asosiy_menyu.visible:
			_inventar_almashtir()
			get_viewport().set_input_as_handled()
	elif event.is_action_pressed("pauza"):
		if dokon_qatlami.visible:
			_dokon_yop()
			get_viewport().set_input_as_handled()
			return
		if inventar_qatlami.visible:
			_inventar_yop()
			get_viewport().set_input_as_handled()
			return
		if asosiy_menyu.visible:
			return
		_pauzani_almashtir()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("saqlash"):
		_saqlash()
	elif event.is_action_pressed("yuklash"):
		_yuklash()

func _topshiriqni_tekshir() -> void:
	if topshiriq.is_empty() or bosqich >= topshiriq.stages.size():
		return
	var stage: Dictionary = topshiriq.stages[bosqich]
	var tur := String(stage.get("type", ""))
	if tur == "reach_area" and oyinchi.global_position.distance_to(belgi.global_position) < 2.4:
		_topshiriq_bosqichini_qoy(bosqich + 1)
	elif tur == "enter_vehicle" and topshiriq_transporti.boshqarilmoqda and oyinchi.joriy_transport == topshiriq_transporti:
		_topshiriq_bosqichini_qoy(bosqich + 1)
	elif tur == "reach_area_vehicle" and topshiriq_transporti.boshqarilmoqda and topshiriq_transporti.global_position.distance_to(belgi.global_position) < 4.2:
		_topshiriq_bosqichini_qoy(bosqich + 1)

func _topshiriq_bosqichini_qoy(yangi_bosqich: int, mukofot_ber := true) -> void:
	if topshiriq.is_empty() or topshiriq.stages.is_empty():
		return
	bosqich = clampi(yangi_bosqich, 0, topshiriq.stages.size() - 1)
	var stage: Dictionary = topshiriq.stages[bosqich]
	var tur := String(stage.get("type", ""))
	if tur == "complete":
		if mukofot_ber:
			pul += int(stage.get("reward", 0))
		belgi.visible = false
		_xabar(String(stage.get("text", "Topshiriq bajarildi")), 8.0)
	else:
		var target: Array = stage.get("target", [0.0, 0.2, 0.0])
		belgi.global_position = Vector3(float(target[0]), float(target[1]), float(target[2]))
		belgi.visible = true
		belgi_yozuvi.text = "MAQSAD %d/%d" % [bosqich + 1, topshiriq.stages.size() - 1]
		_xabar(String(stage.get("text", "Yangi maqsad")), 3.5)

func _hud_yangila() -> void:
	if not hud_yozuvi:
		return
	var holat := "PIYODA"
	var speed := 0
	var transport_holati := ""
	if is_instance_valid(oyinchi.joriy_transport):
		holat = "TRANSPORTDA"
		speed = oyinchi.joriy_transport.tezlik_kmh()
		transport_holati = "  •  Mashina: BUZILMAS" if oyinchi.joriy_transport.buzilmas else "  •  Mashina: %d/%d" % [oyinchi.joriy_transport.mustahkamlik, oyinchi.joriy_transport.maksimal_mustahkamlik]
	hud_yozuvi.text = "TOSHKENT SARGUZASHTI\nJon: %d/100  •  Zirh: %d/100\nPul: %s so‘m\nQurol: %s  •  %s%s" % [sogliq, zirh, _pul_format(pul), oyinchi.faol_qurol_nomi(), holat, transport_holati]
	tezlik_yozuvi.text = "%03d km/soat" % speed if holat == "TRANSPORTDA" else ""
	if topshiriq and not topshiriq.stages.is_empty():
		var stage: Dictionary = topshiriq.stages[bosqich]
		topshiriq_yozuvi.text = "%s — %s" % [topshiriq.get("title", "Topshiriq"), stage.get("text", "")]

func _pul_format(qiymat: int) -> String:
	var s := str(qiymat)
	var natija := ""
	while s.length() > 3:
		natija = " " + s.right(3) + natija
		s = s.left(s.length() - 3)
	return s + natija

func _xabar(matn: String, vaqt := 2.5) -> void:
	if bildirishnoma:
		bildirishnoma.text = matn
		bildirishnoma_vaqti = vaqt

func _pauzani_almashtir() -> void:
	if get_tree().paused:
		_pauzani_yop()
	else:
		get_tree().paused = true
		pauza_qatlami.visible = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _pauzani_yop() -> void:
	get_tree().paused = false
	pauza_qatlami.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _ovoz_ozgardi(qiymat: float) -> void:
	AudioServer.set_bus_volume_db(0, qiymat)

func _oyindan_chiqish() -> void:
	get_tree().quit()

func _saqlash() -> void:
	var data := {
		"schema_version": 2,
		"timestamp": Time.get_datetime_string_from_system(),
		"player": oyinchi.holat_ol(),
		"mission_stage": bosqich,
		"money": pul,
		"health": sogliq,
		"armor": zirh,
		"inventory": oyinchi.inventar,
		"selected_weapon": oyinchi.faol_qurol,
		"vehicle": {
			"position": [topshiriq_transporti.global_position.x, topshiriq_transporti.global_position.y, topshiriq_transporti.global_position.z],
			"rotation_y": topshiriq_transporti.rotation.y,
			"durability": topshiriq_transporti.mustahkamlik
		}
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "  "))
		file.close()
		_xabar("O‘yin saqlandi", 3.0)
	else:
		_xabar("Saqlashda xato", 3.0)

func _yuklash() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		_xabar("Saqlangan o‘yin topilmadi", 3.0)
		return
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH))
	if not parsed is Dictionary:
		_xabar("Save fayli buzilgan", 3.0)
		return
	var data: Dictionary = parsed
	var schema := int(data.get("schema_version", 0))
	if schema not in [1, 2]:
		_xabar("Save versiyasi mos emas", 3.0)
		return
	if is_instance_valid(oyinchi.joriy_transport):
		oyinchi.joriy_transport.chiqish()
	oyinchi.holat_qoy(data.get("player", {}))
	pul = maxi(0, int(data.get("money", 0)))
	sogliq = clampi(int(data.get("health", 100)), 1, 100)
	zirh = clampi(int(data.get("armor", 0)), 0, 100)
	oyinchi.inventar_qoy(data.get("inventory", ["musht"]), String(data.get("selected_weapon", "musht")))
	var transport_data: Dictionary = data.get("vehicle", {})
	topshiriq_transporti.tiklash()
	if transport_data.has("position"):
		var p: Array = transport_data.position
		topshiriq_transporti.global_position = Vector3(float(p[0]), float(p[1]), float(p[2]))
		topshiriq_transporti.rotation.y = float(transport_data.get("rotation_y", 0.0))
	var saqlangan_mustahkamlik := clampi(int(transport_data.get("durability", topshiriq_transporti.maksimal_mustahkamlik)), 0, topshiriq_transporti.maksimal_mustahkamlik)
	if saqlangan_mustahkamlik < topshiriq_transporti.maksimal_mustahkamlik:
		topshiriq_transporti.zarar_ol(topshiriq_transporti.maksimal_mustahkamlik - saqlangan_mustahkamlik)
	_topshiriq_bosqichini_qoy(int(data.get("mission_stage", 0)), false)
	_xabar("Saqlangan o‘yin yuklandi", 3.0)
	if get_tree().paused and not asosiy_menyu.visible:
		_pauzani_yop()

func _yordamchi_preview_holat() -> void:
	# Avtomatik preview shahar va UI’ni yaxshiroq ko‘rsatadigan nuqtadan olinadi.
	oyinchi.global_position = Vector3(0, 0.2, 18)
	oyinchi.rotation.y = PI
	oyinchi.kamera_pivot.rotation.x = deg_to_rad(-12.0)
	oyinchi.inventar_qosh("tayoq")
	yordam_yozuvi.text = "WASD — harakat  |  Sichqon chap — urish  |  I — inventar  |  E — transport/do‘kon"

func _yordamchi_transport_preview_holat() -> void:
	# Original avtomobilning old dizayni va tungi faralari ko‘rinadigan rakurs.
	topshiriq_transporti.global_position = Vector3(0, 0.2, 0)
	topshiriq_transporti.rotation.y = PI
	oyinchi.global_position = Vector3(0, 0.2, 6.2)
	oyinchi.rotation.y = 0.0
	oyinchi.vizual_root.visible = false
	oyinchi.kamera_pivot.rotation.x = deg_to_rad(-7.0)
	oyinchi.prujina.spring_length = 3.4
	yordam_yozuvi.text = "JMJ original shahar avtomobili • avtomatik fara • avtomatik tiklanish"

func _preview_saqlash() -> void:
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	var argumentlar := OS.get_cmdline_user_args()
	var fayl_nomi := "preview_store.png" if argumentlar.has("--capture-store") else ("preview_menu.png" if argumentlar.has("--capture-menu") else ("preview_vehicle.png" if argumentlar.has("--capture-vehicle") else "preview.png"))
	var yol := ProjectSettings.globalize_path("res://screenshots/" + fayl_nomi)
	var xato := image.save_png(yol)
	if xato != OK:
		push_error("Preview saqlanmadi: %s" % xato)
	get_tree().quit()

func _self_test() -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame
	var xatolar: Array[String] = []
	var shahar := get_node_or_null("Shahar")
	if not is_instance_valid(shahar) or shahar.get_child_count() < 40:
		xatolar.append("Procedural shahar to‘liq yaratilmagan")
	if get_tree().get_nodes_in_group("dunyo_chunki").size() != 9:
		xatolar.append("70x70 o‘lchamli 9 ta dunyo chunki yaratilmagan")
	if not is_instance_valid(oyinchi) or not is_instance_valid(oyinchi.kamera) or not oyinchi.kamera.current:
		xatolar.append("Personaj yoki uchinchi shaxs kamerasi yaratilmagan")
	elif oyinchi.oyoq_pivotlari.size() != 2 or oyinchi.qol_pivotlari.size() != 2:
		xatolar.append("Personajning bo‘g‘inli 3D modeli yaratilmagan")
	if get_tree().get_nodes_in_group("transport").size() != 17:
		xatolar.append("Boshqariladigan transport soni noto‘g‘ri")
	if get_tree().get_nodes_in_group("trafik").size() != 16:
		xatolar.append("Trafik soni noto‘g‘ri")
	if get_tree().get_nodes_in_group("piyoda").size() != 44:
		xatolar.append("Piyodalar soni noto‘g‘ri")
	if get_tree().get_nodes_in_group("svetofor").size() != 100:
		xatolar.append("Svetoforlar to‘liq yaratilmagan")
	if get_tree().get_nodes_in_group("tungi_muhit").size() != 1:
		xatolar.append("Doimiy tungi muhit yaratilmagan")
	if get_tree().get_nodes_in_group("shahar_chirogi").size() != 40:
		xatolar.append("Ko‘cha yoritgichlari to‘liq yaratilmagan")
	if get_tree().get_nodes_in_group("avtomobil_farasi").size() != 17:
		xatolar.append("Avtomobil faralari to‘liq yaratilmagan")
	if get_tree().get_nodes_in_group("dokon").size() != 3:
		xatolar.append("Interaktiv do‘konlar yaratilmagan")
	if get_tree().get_nodes_in_group("dunyo_chegarasi").size() != 4:
		xatolar.append("Ko‘rinmas xarita chegaralari yaratilmagan")
	var yol_chetidagi_obyektlar := get_tree().get_nodes_in_group("yol_chetidagi_obyekt")
	if yol_chetidagi_obyektlar.size() != 71:
		xatolar.append("Yo‘l chetidagi obyektlar to‘liq yaratilmagan")
	for obyekt in yol_chetidagi_obyektlar:
		if _yol_ustidami(obyekt.global_position, 0.70):
			xatolar.append("Ko‘cha jihozi yo‘l ustiga tushib qolgan: %s" % obyekt.name)
			break
	if topshiriq.get("stages", []).size() != 4:
		xatolar.append("Topshiriq bosqichlari yuklanmadi")
	if not is_instance_valid(hud_yozuvi) or not is_instance_valid(topshiriq_yozuvi) or not is_instance_valid(minimap):
		xatolar.append("HUD yoki minimap yaratilmagan")
	if not is_instance_valid(asosiy_menyu) or not is_instance_valid(pauza_qatlami):
		xatolar.append("Asosiy yoki pause menyusi yaratilmagan")
	elif pauza_qatlami.find_children("*", "HSlider", true, false).size() != 1:
		xatolar.append("Ovoz sozlamasi topilmadi")
	if not is_instance_valid(asosiy_menyu.find_child("JMJGems", true, false)):
		xatolar.append("Kirish menyusida by JMJ gems yozuvi topilmadi")
	if not is_instance_valid(inventar_qatlami) or not is_instance_valid(dokon_qatlami):
		xatolar.append("Inventar yoki do‘kon oynasi yaratilmagan")

	_asosiy_menyuni_och()
	if not get_tree().paused or not asosiy_menyu.visible:
		xatolar.append("Asosiy menyu pause holatini yoqmadi")
	_yangi_oyin()
	if get_tree().paused or asosiy_menyu.visible:
		xatolar.append("Yangi o‘yin menyudan to‘g‘ri boshlanmadi")
	_pauzani_almashtir()
	if not get_tree().paused or not pauza_qatlami.visible:
		xatolar.append("Pause menyusi ochilmadi")
	_pauzani_yop()
	if get_tree().paused or pauza_qatlami.visible:
		xatolar.append("Pause menyusi yopilmadi")

	zirh = 20
	sogliq = 100
	oyinchi.zarar_ol(20, null)
	if sogliq != 93 or zirh != 7:
		xatolar.append("Jon va zirh zarar tizimi noto‘g‘ri")
	sogliq = 100
	zirh = 0
	pul = 50000
	joriy_dokon = get_tree().get_first_node_in_group("dokon")
	_mahsulot_sotib_ol("tayoq")
	await get_tree().process_frame
	if not oyinchi.inventar.has("tayoq") or pul != 38000 or oyinchi.faol_qurol != "tayoq" or not oyinchi.qurol_modellari["tayoq"].visible:
		xatolar.append("Do‘kon xaridi yoki inventar ishlamadi")
	oyinchi.inventar_qosh("elektroshoker")
	if oyinchi.faol_qurol != "elektroshoker" or not oyinchi.qurol_modellari["elektroshoker"].visible or oyinchi.qurol_modellari["tayoq"].visible:
		xatolar.append("Qurol modeli qo‘lda to‘g‘ri almashmadi")
	oyinchi.inventar_qoy(["musht"], "musht")
	pul = 0
	oyinchi._hujum()
	if oyinchi.hujum_animatsiyasi <= 0.0 or oyinchi.hujum_zarba_bajarildi:
		xatolar.append("Uch bosqichli urish animatsiyasi boshlanmadi")
	oyinchi.hujum_animatsiyasi = 0.0
	oyinchi.hujum_sovush_vaqti = 0.0
	topshiriq_transporti.zarar_ol(9999)
	if topshiriq_transporti.mustahkamlik != topshiriq_transporti.maksimal_mustahkamlik or topshiriq_transporti.vayron:
		xatolar.append("Boshqariladigan transport buzilmas holatda qolmadi")
	if int(round(topshiriq_transporti.maksimal_tezlik * 3.6)) != 270:
		xatolar.append("Tezkor transport sozlamasi noto‘g‘ri")
	topshiriq_transporti.joriy_tezlik = 18.0
	topshiriq_transporti.boshqaruv_tezligini_yangila(0.0, false, 1.0)
	if topshiriq_transporti.joriy_tezlik >= 18.0 or topshiriq_transporti.joriy_tezlik < 16.0:
		xatolar.append("Gaz qo‘yib yuborilganda transport yumshoq sekinlashmadi")
	var erkin_tezlik: float = float(topshiriq_transporti.joriy_tezlik)
	topshiriq_transporti.boshqaruv_tezligini_yangila(1.0, false, 0.5)
	if topshiriq_transporti.joriy_tezlik <= erkin_tezlik:
		xatolar.append("Gaz bosilganda transport tezligi oshmadi")
	var gazdan_keyingi_tezlik: float = float(topshiriq_transporti.joriy_tezlik)
	topshiriq_transporti.boshqaruv_tezligini_yangila(-1.0, false, 0.5)
	if topshiriq_transporti.joriy_tezlik >= gazdan_keyingi_tezlik:
		xatolar.append("Tormoz bosilganda transport tezligi kamaymadi")
	topshiriq_transporti.joriy_tezlik = 0.0
	if topshiriq_transporti.salon_zarari_hisobla(12) != 0 or topshiriq_transporti.salon_zarari_hisobla(999) != 0:
		xatolar.append("Transport ichida o‘yinchi joni himoyalanmadi")
	var sinov_trafik = get_tree().get_first_node_in_group("trafik")
	if is_instance_valid(sinov_trafik):
		if not sinov_trafik.has_method("kirish") or not sinov_trafik.has_method("chiqish"):
			xatolar.append("Trafik avtomobilini egallash interfeysi yo‘q")
		else:
			var eski_joy: Vector3 = sinov_trafik.global_position
			sinov_trafik.global_position = Vector3(12, TRANSPORT_YER_SATHI, 12)
			oyinchi.global_position = Vector3(10, 0.2, 12)
			sinov_trafik.kirish(oyinchi)
			if not sinov_trafik.boshqarilmoqda or oyinchi.joriy_transport != sinov_trafik:
				xatolar.append("Trafik avtomobilini egallab bo‘lmadi")
			sinov_trafik.joriy_tezlik = 0.0
			sinov_trafik.chiqish(true)
			if sinov_trafik.boshqarilmoqda or is_instance_valid(oyinchi.joriy_transport):
				xatolar.append("Egallangan trafik avtomobilidan tushib bo‘lmadi")
			sinov_trafik.global_position = eski_joy
		sinov_trafik.global_position.y = 4.0
		await get_tree().physics_frame
		await get_tree().physics_frame
		if absf(sinov_trafik.global_position.y - TRANSPORT_YER_SATHI) > 0.01 or absf(sinov_trafik.rotation.x) > 0.01 or absf(sinov_trafik.rotation.z) > 0.01:
			xatolar.append("Trafik avtomobili yer sathiga qaytmadi")
		sinov_trafik.zarar_ol(999)
		if not sinov_trafik.vayron or sinov_trafik.tiklanish_vaqti <= 0.0:
			xatolar.append("Trafik avtomobilining avtomatik tiklanishi boshlanmadi")
		sinov_trafik._avtomatik_tiklash()
		if sinov_trafik.vayron or sinov_trafik.mustahkamlik != sinov_trafik.maksimal_mustahkamlik:
			xatolar.append("Trafik avtomobili nosoz holatdan tiklanmadi")
	var sinov_piyoda = get_tree().get_first_node_in_group("piyoda")
	if is_instance_valid(sinov_piyoda):
		oyinchi.global_position = sinov_piyoda.global_position + Vector3(0.0, 0.0, 2.0)
		var piyoda_boshlangich_y: float = float(sinov_piyoda.global_position.y)
		sinov_piyoda.zarar_ol(18, oyinchi)
		if sinov_piyoda.zarba_vertikal_tezligi <= 0.0 or sinov_piyoda.zarba_tezligi.length() < 3.5 or sinov_piyoda.zarba_vaqti < 1.0:
			xatolar.append("Piyoda zarbadan havoga uchmadi")
		await get_tree().physics_frame
		await get_tree().physics_frame
		if sinov_piyoda.global_position.y <= piyoda_boshlangich_y + 0.01:
			xatolar.append("Piyoda zarbadan yuqoriga ko‘tarilmadi: %.3f -> %.3f, vy=%.3f, t=%.3f" % [piyoda_boshlangich_y, sinov_piyoda.global_position.y, sinov_piyoda.zarba_vertikal_tezligi, sinov_piyoda.zarba_vaqti])
		sinov_piyoda.zarar_immun_vaqti = 0.0
		sinov_piyoda.zarar_ol(999, oyinchi)
		if get_tree().get_nodes_in_group("pul_pickup").is_empty():
			xatolar.append("Piyoda halok bo‘lganda pul tushmadi")
		sinov_piyoda.queue_free()
	for pickup in get_tree().get_nodes_in_group("pul_pickup"):
		pickup.queue_free()
	await get_tree().process_frame

	oyinchi.global_position = belgi.global_position
	_topshiriqni_tekshir()
	if bosqich != 1:
		xatolar.append("Reach-area bosqichi ishlamadi")

	topshiriq_transporti.kirish(oyinchi)
	topshiriq_transporti.rotation.y = 0.72
	await get_tree().physics_frame
	await get_tree().physics_frame
	_topshiriqni_tekshir()
	if bosqich != 2 or oyinchi.joriy_transport != topshiriq_transporti:
		xatolar.append("Transportga kirish bosqichi ishlamadi")
	if not topshiriq_transporti.haydovchi_modeli.visible:
		xatolar.append("Transport ichidagi haydovchi modeli ko‘rinmadi")
	if abs(angle_difference(oyinchi.rotation.y, topshiriq_transporti.rotation.y)) > 0.08:
		xatolar.append("Transport kamerasi avtomatik old tomonga burilmadi")

	topshiriq_transporti.global_position = belgi.global_position
	_topshiriqni_tekshir()
	if bosqich != 3 or pul != 25000:
		xatolar.append("Topshiriq yakuni yoki mukofot ishlamadi")

	_saqlash()
	if not FileAccess.file_exists(SAVE_PATH):
		xatolar.append("Save fayli yaratilmagan")
	else:
		pul = 0
		_yuklash()
		if pul != 25000:
			xatolar.append("Save/load pul qiymatini tiklamadi")

	if xatolar.is_empty():
		print("SELF_TEST_OK: dunyo=210x210 chunk=9 yol=toza tun=doimiy chiroq=40 fara=17 transport=270kmh+buzilmas+yumshoq_sekinlash trafik=16+egallanadi parvoz=yoq piyoda=44+zarba_uchishi svetofor=100 dokon=3 zarar=muvozanatli salon_joni=100foiz pul_drop=OK inventar=qurol_qolda urish=3_bosqich avto_tiklash=OK optimizatsiya=LOD+kesh kamera=avto_old mission=4 save_v2=OK")
		await get_tree().process_frame
		get_tree().quit(0)
	else:
		for xato in xatolar:
			push_error("SELF_TEST: " + xato)
		get_tree().quit(1)

