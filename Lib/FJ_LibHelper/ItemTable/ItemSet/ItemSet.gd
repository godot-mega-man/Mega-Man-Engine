#Item Set
#Code by : First

#ItemSet เป็นชุดไอเทม 1 ชุดที่ประกอบด้วยไอเท็มหลายๆไอเทม ข้างในนั้น
#จะเป็น Resource เก็บชื่อไอเท็มและน้ำหนักที่เซตหนึ่งจะคำนวณสุ่มเลือกมา
#1 ไอเท็ม ยิ่งไอเท็มมีน้ำหนักมากยิ่งมีโอกาสสูงที่ไอเท็มนั้นจะถูกเลือก

#ตัวอย่าง
# ┖╴ItemTable
#    ┖╴ItemSet
#       ┖╴ItemSetData1
#          ┠╴Sword - น้ำหนัก 10
#          ┠╴Potion - น้ำหนัก 40 จำนวน 2
#          ┖╴null - น้ำหนัก 50
# จากตัวอย่างข้างต้น จะเห็นว่าแต่ละไอเท็มมีน้ำหนักไม่เท่ากัน โดยคร่าวๆคือ
# จะมีโอกาสที่ Potion ดรอป 40%  Sword ดรอป 10 % และ 50% ไม่ดรอป
# อะไรเลย
# หรือถ้าทดลองเปลี่ยน null ให้มีค่าน้ำหนักเป็น 100 จะเปลี่ยนโอกาสทั้งหมด
# ของไอเทมอื่นๆ ไปด้วย นั่นหมายความว่า Potion จะมีโอกาสดรอป 26%
# Sword จะมีโอกาสดรอป 6.6% และ 66% ไม่ดรอปอะไรเลย

tool
extends Node

class_name ItemSet

export (Array, Resource) var items : Array setget _set_items

func _set_items(val):
	items = val
	
	_replace_last_with_empty_item_set_data()

#อันนี้ทำอัตโนมัติเมื่อขนาด Array ของ items ถูกเปลี่ยนแปลง
func _replace_last_with_empty_item_set_data():
	if items.size() == 0:
		return
	
	#If at the end of an array is empty, we replace
	#empty one with a new ItemSetData.
	if items.back() == null:
		items.remove(items.size() - 1)
		var new_item_set_data = ItemSetData.new()
		items.append(new_item_set_data)


func get_an_item() -> ItemSetData:
	#ไม่ต้องทำอะไรถ้าในเซตไม่มีไอเท็มโดยคืนค่า null ไป
	if items.size() == 0:
		return null
	
	#วนลูป 1 รอบเพื่อคำนวณน้ำหนักทั้งหมดในเซต
	var overall_weight : int
	for i in items:
		if i is ItemSetData:
			overall_weight += i.weight
	
	#เมื่อได้น้ำหนักโดยรวมแล้ว สุ่มตัวเลขระหว่าง 1 - (overall_weight)
	var val = randi() % overall_weight + 1
	
	#คืนค่า item ไปตาม weight
	var _temp_current := 0
	for i in items:
		if i is ItemSetData:
			if within_numbers(val, _temp_current + 1, _temp_current + i.weight):
				return i 
			_temp_current += i.weight
	
	return null

func within_numbers(val : int, min_val : int, max_val : int) -> bool:
	return val >= min_val && val <= max_val