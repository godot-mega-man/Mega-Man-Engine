#Item Set - Data
#Code by: First

#ItemSetData ใช้เป็นข้อมูลสำหรับ ItemSet ซึ่งข้อมูลจะประกอบไปด้วย
# item - ไอเท็ม
# weight - น้ำหนักของไอเท็ม ใช้คำนวณค่าความหายาก (drop rate)

extends Resource

class_name ItemSetData

export (String, FILE, "*.tres") var item
export (int) var weight : int = 10 setget _set_weight
export (int, 1, 255) var quantity : int = 1

func _init() -> void:
	weight = 10

#กั้นไว้ไม่ให้เป็นเลข 0 หรือต่ำกว่า
func _set_weight(val : int):
	if val <= 0:
		val = 1
	weight = val