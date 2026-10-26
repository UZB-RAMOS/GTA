extends Node

var oyinchi: CharacterBody3D
var ob_havo: Node
var shahar_ovozi: AudioStreamPlayer
var yomgir_ovozi: AudioStreamPlayer
var motor_ovozi: AudioStreamPlayer3D
var qadam_ovozi: AudioStreamPlayer3D
var signal_ovozi: AudioStreamPlayer
var eshik_ovozi: AudioStreamPlayer3D
var missiya_ovozi: AudioStreamPlayer
var qadam_vaqti := 0.0

func sozla(yangi_oyinchi: CharacterBody3D, yangi_ob_havo: Node) -> void:
	add_to_group("audio_tizimi")
	oyinchi = yangi_oyinchi
	ob_havo = yangi_ob_havo
	shahar_ovozi = AudioStreamPlayer.new()
	shahar_ovozi.name = "ShaharAtmosferasi"
	shahar_ovozi.stream = _shovqin_yarat(1.8, 85.0, 0.045, true)
	shahar_ovozi.volume_db = -27.0
	add_child(shahar_ovozi)
	shahar_ovozi.play()

	yomgir_ovozi = AudioStreamPlayer.new()
	yomgir_ovozi.name = "YomgirOvozi"
	yomgir_ovozi.stream = _shovqin_yarat(1.4, 1200.0, 0.13, true)
	yomgir_ovozi.volume_db = -80.0
	add_child(yomgir_ovozi)
	yomgir_ovozi.play()

	motor_ovozi = AudioStreamPlayer3D.new()
	motor_ovozi.name = "TransportMotorOvozi"
	motor_ovozi.stream = _ton_yarat(1.0, 62.0, 0.13, true)
	motor_ovozi.volume_db = -80.0
	motor_ovozi.max_distance = 42.0
	motor_ovozi.unit_size = 5.0
	add_child(motor_ovozi)
	motor_ovozi.play()

	qadam_ovozi = AudioStreamPlayer3D.new()
	qadam_ovozi.name = "QadamOvozi"
	qadam_ovozi.stream = _shovqin_yarat(0.08, 180.0, 0.22, false)
	qadam_ovozi.volume_db = -15.0
	qadam_ovozi.max_distance = 18.0
	add_child(qadam_ovozi)

	signal_ovozi = AudioStreamPlayer.new()
	signal_ovozi.name = "InterfeysOvozi"
	signal_ovozi.stream = _ton_yarat(0.13, 620.0, 0.16, false)
	signal_ovozi.volume_db = -13.0
	add_child(signal_ovozi)

	eshik_ovozi = AudioStreamPlayer3D.new()
	eshik_ovozi.name = "EshikOvozi"
	eshik_ovozi.stream = _shovqin_yarat(0.24, 260.0, 0.18, false)
	eshik_ovozi.volume_db = -11.0
	eshik_ovozi.max_distance = 24.0
	add_child(eshik_ovozi)

	missiya_ovozi = AudioStreamPlayer.new()
	missiya_ovozi.name = "MissiyaOvozi"
	missiya_ovozi.stream = _ton_yarat(0.34, 740.0, 0.14, false)
	missiya_ovozi.volume_db = -10.0
	add_child(missiya_ovozi)

func _process(delta: float) -> void:
	if not is_instance_valid(oyinchi):
		return
	var transport = oyinchi.joriy_transport
	if is_instance_valid(transport):
		motor_ovozi.global_position = transport.global_position
		var nisbat: float = clampf(absf(transport.joriy_tezlik) / maxf(transport.maksimal_tezlik, 0.1), 0.0, 1.0)
		motor_ovozi.volume_db = lerpf(-18.0, -7.0, nisbat)
		motor_ovozi.pitch_scale = lerpf(0.78, 1.75, nisbat)
	else:
		motor_ovozi.volume_db = -80.0
	qadam_ovozi.global_position = oyinchi.global_position
	if oyinchi.faol and oyinchi.is_on_floor() and Vector2(oyinchi.velocity.x, oyinchi.velocity.z).length() > 0.8:
		qadam_vaqti -= delta
		if qadam_vaqti <= 0.0:
			qadam_vaqti = 0.34 if Vector2(oyinchi.velocity.x, oyinchi.velocity.z).length() > 5.0 else 0.48
			qadam_ovozi.pitch_scale = randf_range(0.92, 1.08)
			qadam_ovozi.play()
	else:
		qadam_vaqti = 0.0
	if is_instance_valid(ob_havo):
		var yomgirli: bool = ob_havo.joriy_rejim in ["yengil_yomgir", "kuchli_yomgir"]
		yomgir_ovozi.volume_db = (-17.0 if ob_havo.joriy_rejim == "kuchli_yomgir" else -23.0) if yomgirli else -80.0

func ui_signal() -> void:
	if is_instance_valid(signal_ovozi):
		signal_ovozi.play()

func intro_signal() -> void:
	if not is_instance_valid(signal_ovozi):
		return
	signal_ovozi.pitch_scale = 0.72
	signal_ovozi.play()
	var tween := create_tween()
	tween.tween_interval(0.42)
	tween.tween_callback(func():
		signal_ovozi.pitch_scale = 1.08
		signal_ovozi.play()
	)

func eshik_signal() -> void:
	if not is_instance_valid(eshik_ovozi):
		return
	if is_instance_valid(oyinchi):
		eshik_ovozi.global_position = oyinchi.global_position
	eshik_ovozi.pitch_scale = randf_range(0.88, 1.05)
	eshik_ovozi.play()

func missiya_signal(muvaffaqiyatli := true) -> void:
	if not is_instance_valid(missiya_ovozi):
		return
	missiya_ovozi.pitch_scale = 1.15 if muvaffaqiyatli else 0.62
	missiya_ovozi.play()

func tozalash() -> void:
	for player in [shahar_ovozi, yomgir_ovozi, motor_ovozi, qadam_ovozi, signal_ovozi, eshik_ovozi, missiya_ovozi]:
		if is_instance_valid(player):
			player.stop()
			player.stream = null

func _exit_tree() -> void:
	tozalash()

func _ton_yarat(davomiylik: float, chastota: float, kuch: float, loop: bool) -> AudioStreamWAV:
	var mix_rate := 22050
	var namuna_soni := maxi(1, int(davomiylik * mix_rate))
	var data := PackedByteArray()
	data.resize(namuna_soni * 2)
	for i in range(namuna_soni):
		var qobiq := minf(1.0, float(i) / 180.0) * minf(1.0, float(namuna_soni - i) / 180.0)
		var sample := int(sin(TAU * chastota * float(i) / float(mix_rate)) * 32767.0 * kuch * qobiq)
		data.encode_s16(i * 2, sample)
	return _wav_yarat(data, mix_rate, loop)

func _shovqin_yarat(davomiylik: float, filtr_chastotasi: float, kuch: float, loop: bool) -> AudioStreamWAV:
	var mix_rate := 22050
	var namuna_soni := maxi(1, int(davomiylik * mix_rate))
	var data := PackedByteArray()
	data.resize(namuna_soni * 2)
	var rng := RandomNumberGenerator.new()
	rng.seed = 20261026 + int(filtr_chastotasi)
	var silliq := 0.0
	var alpha: float = clampf(filtr_chastotasi / float(mix_rate), 0.002, 0.28)
	for i in range(namuna_soni):
		silliq = lerpf(silliq, rng.randf_range(-1.0, 1.0), alpha)
		var qobiq := 1.0 if loop else minf(1.0, float(namuna_soni - i) / 300.0)
		data.encode_s16(i * 2, int(clampf(silliq * kuch * qobiq, -1.0, 1.0) * 32767.0))
	return _wav_yarat(data, mix_rate, loop)

func _wav_yarat(data: PackedByteArray, mix_rate: int, loop: bool) -> AudioStreamWAV:
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = mix_rate
	wav.stereo = false
	wav.data = data
	if loop:
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wav.loop_begin = 0
		wav.loop_end = data.size() / 2
	return wav
