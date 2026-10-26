extends Node

var oyinchi: Node3D
var yuklash_radiusi := 108.0
var yangilash_oraligi := 0.35
var qolgan_vaqt := 0.0
var faol_chunklar := 0
var chunklar: Array[Node] = []

func sozla(yangi_oyinchi: Node3D, radius: float) -> void:
	oyinchi = yangi_oyinchi
	yuklash_radiusi = maxf(radius, 72.0)
	chunklarni_qayta_top()
	_yangila(true)

func chunklarni_qayta_top() -> void:
	chunklar.clear()
	for chunk in get_tree().get_nodes_in_group("dunyo_chunki"):
		if is_instance_valid(chunk):
			chunklar.append(chunk)
	_yangila(true)

func _process(delta: float) -> void:
	qolgan_vaqt -= delta
	if qolgan_vaqt <= 0.0:
		qolgan_vaqt = yangilash_oraligi
		_yangila(false)

func _yangila(majburiy: bool) -> void:
	if not is_instance_valid(oyinchi):
		return
	var o := Vector2(oyinchi.global_position.x, oyinchi.global_position.z)
	var sanoq := 0
	for chunk in chunklar:
		if not is_instance_valid(chunk):
			continue
		var markaz: Vector2 = chunk.get_meta("markaz", Vector2(chunk.global_position.x, chunk.global_position.z))
		var faol := o.distance_to(markaz) <= yuklash_radiusi
		if not faol and o.distance_to(markaz) < 50.0:
			faol = true
		if majburiy or chunk.visible != faol:
			chunk.visible = faol
			chunk.process_mode = Node.PROCESS_MODE_PAUSABLE if faol else Node.PROCESS_MODE_DISABLED
			chunk.set_meta("faol", faol)
		if faol:
			sanoq += 1
	faol_chunklar = sanoq

func radiusni_qoy(radius: float) -> void:
	yuklash_radiusi = maxf(radius, 72.0)
	_yangila(true)

func faol_soni() -> int:
	return faol_chunklar
