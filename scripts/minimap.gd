extends Control

var oyinchi: Node3D
var dunyo_radiusi := 104.0
var dunyo_min := Vector2(-104.0, -104.0)
var dunyo_max := Vector2(174.0, 104.0)
var x_yollar := [-70.0, -35.0, 0.0, 35.0, 70.0, 140.0]
var z_yollar := [-70.0, -35.0, 0.0, 35.0, 70.0]
var yangilash_vaqti := 0.0

func _ready() -> void:
	custom_minimum_size = Vector2(180, 180)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()

func _process(delta: float) -> void:
	yangilash_vaqti -= delta
	if yangilash_vaqti <= 0.0:
		yangilash_vaqti = 0.10
		queue_redraw()

func _draw() -> void:
	var markaz := size * 0.5
	draw_circle(markaz, min(size.x, size.y) * 0.49, Color(0.03, 0.06, 0.08, 0.82))
	var dunyo_markazi := (dunyo_min + dunyo_max) * 0.5
	var dunyo_hajmi := dunyo_max - dunyo_min
	var masshtab := minf(size.x / dunyo_hajmi.x, size.y / dunyo_hajmi.y) * 0.94
	var yol_rangi := Color(0.42, 0.46, 0.5, 0.95)
	for z in z_yollar:
		var a := markaz + (Vector2(dunyo_min.x, z) - dunyo_markazi) * masshtab
		var b := markaz + (Vector2(dunyo_max.x, z) - dunyo_markazi) * masshtab
		draw_line(a, b, yol_rangi, 7.0)
	for x in x_yollar:
		var a := markaz + (Vector2(x, dunyo_min.y) - dunyo_markazi) * masshtab
		var b := markaz + (Vector2(x, dunyo_max.y) - dunyo_markazi) * masshtab
		draw_line(a, b, yol_rangi, 7.0)
	if is_instance_valid(oyinchi):
		var p := Vector2(oyinchi.global_position.x, oyinchi.global_position.z)
		var nuqta := markaz + (p - dunyo_markazi) * masshtab
		draw_circle(nuqta, 6.0, Color("34e27a"))
		var old := Vector2(-oyinchi.global_transform.basis.z.x, -oyinchi.global_transform.basis.z.z)
		draw_line(nuqta, nuqta + old * 13.0, Color.WHITE, 3.0)

