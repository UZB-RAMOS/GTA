extends Node

const MATNLAR := {
	"uz": {
		"mission_failed": "Topshiriq bajarilmadi",
		"retry": "R — qayta urinish",
		"entered": "%s ichiga kirdingiz",
		"exited": "%s dan chiqdingiz",
		"vehicle_bought": "%s transporti sotib olindi",
		"save_recovered": "Asosiy save buzilgan: zaxira nusxa tiklandi"
	},
	"ru": {
		"mission_failed": "Задание провалено",
		"retry": "R — повторить",
		"entered": "Вы вошли: %s",
		"exited": "Вы вышли: %s",
		"vehicle_bought": "Транспорт куплен: %s",
		"save_recovered": "Основное сохранение повреждено: восстановлена резервная копия"
	},
	"en": {
		"mission_failed": "Mission failed",
		"retry": "R — retry",
		"entered": "Entered %s",
		"exited": "Exited %s",
		"vehicle_bought": "%s purchased",
		"save_recovered": "Primary save was damaged: backup restored"
	}
}

var til := "uz"

func matn(kalit: String, qiymatlar: Array = []) -> String:
	var lugat: Dictionary = MATNLAR.get(til, MATNLAR.uz)
	var natija := String(lugat.get(kalit, MATNLAR.uz.get(kalit, kalit)))
	return natija % qiymatlar if not qiymatlar.is_empty() else natija

func tilni_qoy(yangi_til: String) -> void:
	if MATNLAR.has(yangi_til):
		til = yangi_til

func mavjud_tillar() -> Array[String]:
	return ["uz", "ru", "en"]
