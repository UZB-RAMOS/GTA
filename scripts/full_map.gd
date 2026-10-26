extends Control

var oyinchi: Node3D
var maqsad: Node3D
var dunyo_radiusi := 104.0
var zoom := 1.0
var yangilash_vaqti := 0.0

const HUDUDLAR := [
	["MARKAZ", Vector2(18, -52), Color("f2d27a")],
	["TASHKENT CITY", Vector2(52, 52), Color("6ed6ef")],
	["CHORSU", Vector2(-18, -18), Color("64d4a1")],
	["CHILONZOR", Vector2(-52, 53), Color("e79768")],
	["YUNUSOBOD", Vector2(86, -52), Color("af9cf4")],
	["SERGELI", Vector2(-52, -52), Color("e7a6ba")],
	["MUSTAQILLIK", Vector2(18, 87), Color("f1d36c")],
	["MINOR", Vector2(87, 52), Color("6ed8d5")],
	["TUNGI SAYILGOH", Vector2(52, 87), Color("ef72d8")],
	["VOKZAL", Vector2(-52, 87), Color("d1aa74")],
	["METRO", Vector2(87, -87), Color("55b8ef")]
]

func _ready() -> void:
	custom_minimum_size = Vector2(760, 620)
	mouse_filter = Control.MOUSE_FILTER_STOP
	queue_redraw()

func _process(delta: float) -> void:
	yangilash_vaqti -= delta
	if yangilash_vaqti <= 0.0:
		yangilash_vaqti = 0.12
		queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom = minf(2.4, zoom + 0.2)
			queue_redraw()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom = maxf(1.0, zoom - 0.2)
			queue_redraw()

func _dunyo_nuqta(p: Vector2) -> Vector2:
	var markaz := size * 0.5
	var fokus := Vector2.ZERO
	if zoom > 1.0 and is_instance_valid(oyinchi):
		fokus = Vector2(oyinchi.global_position.x, oyinchi.global_position.z)
	var masshtab := minf(size.x, size.y) / (dunyo_radiusi * 2.25) * zoom
	return markaz + (p - fokus) * masshtab

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.015, 0.035, 0.055, 0.97), true)
	var yol_rangi := Color(0.34, 0.39, 0.44, 0.95)
	for koordinata in [-70.0, -35.0, 0.0, 35.0, 70.0]:
		var a := _dunyo_nuqta(Vector2(-104, koordinata))
		var b := _dunyo_nuqta(Vector2(104, koordinata))
		draw_line(a, b, yol_rangi, 12.0 * zoom)
		a = _dunyo_nuqta(Vector2(koordinata, -104))
		b = _dunyo_nuqta(Vector2(koordinata, 104))
		draw_line(a, b, yol_rangi, 12.0 * zoom)
	for hudud in HUDUDLAR:
		var nuqta := _dunyo_nuqta(hudud[1])
		draw_circle(nuqta, 7.0, hudud[2])
		draw_string(ThemeDB.fallback_font, nuqta + Vector2(10, 5), String(hudud[0]), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, hudud[2])
	for dokon in get_tree().get_nodes_in_group("dokon"):
		var d := _dunyo_nuqta(Vector2(dokon.global_position.x, dokon.global_position.z))
		draw_rect(Rect2(d - Vector2(5, 5), Vector2(10, 10)), Color("68f0a4"), true)
	for interyer in get_tree().get_nodes_in_group("interyer"):
		var ichki := _dunyo_nuqta(Vector2(interyer.global_position.x, interyer.global_position.z))
		draw_rect(Rect2(ichki - Vector2(5, 5), Vector2(10, 10)), Color("f0b868"), false, 2.0)
	for garaj in get_tree().get_nodes_in_group("garaj"):
		var g := _dunyo_nuqta(Vector2(garaj.global_position.x, garaj.global_position.z))
		draw_circle(g, 7.0, Color("8db6ff"), false, 2.0)
	if is_instance_valid(maqsad) and maqsad.visible:
		var m := _dunyo_nuqta(Vector2(maqsad.global_position.x, maqsad.global_position.z))
		draw_circle(m, 10.0, Color("ffd84f"), false, 3.0)
	if is_instance_valid(oyinchi):
		var p := _dunyo_nuqta(Vector2(oyinchi.global_position.x, oyinchi.global_position.z))
		draw_circle(p, 8.0, Color("30e978"))
		var old := Vector2(-oyinchi.global_transform.basis.z.x, -oyinchi.global_transform.basis.z.z)
		draw_line(p, p + old * 18.0, Color.WHITE, 4.0)
	draw_string(ThemeDB.fallback_font, Vector2(18, 28), "TOSHKENT XARITASI  •  g‘ildirak: zoom  •  M/Esc: yopish", HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("f7e6a1"))
