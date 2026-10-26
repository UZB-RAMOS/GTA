extends Node

const YOL_SATHI := -0.10
const QATOR_SILJISHI := 2.15
const NUQTA_ORALIGI := 11.5

var marshrutlar: Array = []
var barcha_tugunlar: Array[Vector3] = []

func _ready() -> void:
	name = "ToshkentYolGrafigi"
	add_to_group("navigation_graph")
	_graf_qur()

func _graf_qur() -> void:
	marshrutlar.clear()
	barcha_tugunlar.clear()
	# Har bir aylana o‘ng tomonlama harakat uchun soat yo‘nalishida quriladi.
	for chegara in [
		[-70.0, 70.0, -70.0, 70.0],
		[-35.0, 35.0, -35.0, 35.0],
		[-70.0, 35.0, -70.0, 35.0],
		[-35.0, 70.0, -35.0, 70.0],
		[-70.0, 0.0, 0.0, 70.0],
		[0.0, 70.0, -70.0, 0.0]
	]:
		var marshrut := _tortburchak_marshrut(float(chegara[0]), float(chegara[1]), float(chegara[2]), float(chegara[3]))
		marshrutlar.append(marshrut)
		for tugun in marshrut:
			barcha_tugunlar.append(tugun)

func _tortburchak_marshrut(min_x: float, max_x: float, min_z: float, max_z: float) -> Array[Vector3]:
	var natija: Array[Vector3] = []
	var shimoli_garb := Vector3(min_x + QATOR_SILJISHI, YOL_SATHI, min_z + QATOR_SILJISHI)
	var shimoli_sharq := Vector3(max_x - QATOR_SILJISHI, YOL_SATHI, min_z + QATOR_SILJISHI)
	var janubi_sharq := Vector3(max_x - QATOR_SILJISHI, YOL_SATHI, max_z - QATOR_SILJISHI)
	var janubi_garb := Vector3(min_x + QATOR_SILJISHI, YOL_SATHI, max_z - QATOR_SILJISHI)
	_kesma_qosh(natija, shimoli_garb, shimoli_sharq)
	_kesma_qosh(natija, shimoli_sharq, janubi_sharq)
	_kesma_qosh(natija, janubi_sharq, janubi_garb)
	_kesma_qosh(natija, janubi_garb, shimoli_garb)
	return natija

func _kesma_qosh(natija: Array[Vector3], boshlanish: Vector3, yakun: Vector3) -> void:
	var qadam_soni := maxi(1, ceili(boshlanish.distance_to(yakun) / NUQTA_ORALIGI))
	for i in range(qadam_soni):
		var t := float(i) / float(qadam_soni)
		var nuqta := boshlanish.lerp(yakun, t)
		if natija.is_empty() or natija[-1].distance_squared_to(nuqta) > 0.01:
			natija.append(nuqta)

func marshrut_ol(indeks: int) -> Array[Vector3]:
	if marshrutlar.is_empty():
		_graf_qur()
	var manba: Array = marshrutlar[posmod(indeks, marshrutlar.size())]
	var natija: Array[Vector3] = []
	for nuqta in manba:
		natija.append(nuqta)
	return natija

func eng_yaqin_tugun(joy: Vector3) -> Vector3:
	var eng_yaqin := Vector3.ZERO
	var eng_masofa := INF
	for tugun in barcha_tugunlar:
		var masofa := joy.distance_squared_to(tugun)
		if masofa < eng_masofa:
			eng_masofa = masofa
			eng_yaqin = tugun
	return eng_yaqin

func holat_ol() -> Dictionary:
	return {
		"marshrutlar": marshrutlar.size(),
		"tugunlar": barcha_tugunlar.size(),
		"ong_tomonlama": true
	}
