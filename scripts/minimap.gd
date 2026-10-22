extends Control

var oyinchi: Node3D
var dunyo_radiusi := 104.0
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
	var masshtab := size.x / (dunyo_radiusi * 2.0)
	var yol_rangi := Color(0.42, 0.46, 0.5, 0.95)
	for koordinata in [-70.0, -35.0, 0.0, 35.0, 70.0]:
		var ekran: float = float(koordinata) * masshtab
		draw_rect(Rect2(Vector2(0, markaz.y + ekran - 5), Vector2(size.x, 10)), yol_rangi)
		draw_rect(Rect2(Vector2(markaz.x + ekran - 5, 0), Vector2(10, size.y)), yol_rangi)
	if is_instance_valid(oyinchi):
		var p := Vector2(oyinchi.global_position.x, oyinchi.global_position.z) * masshtab
		var nuqta := markaz + p
		draw_circle(nuqta, 6.0, Color("34e27a"))
		var old := Vector2(-oyinchi.global_transform.basis.z.x, -oyinchi.global_transform.basis.z.z)
		draw_line(nuqta, nuqta + old * 13.0, Color.WHITE, 3.0)

