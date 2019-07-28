#Item Table
#Code by: First

#ไอเท็มเทเบิล เป็นตัวเก็บ ItemSet โดยสามารถใช้เป็นข้อมูล Reference
#เช่น ศัตรู 1 ตัวดรอปอะไรบ้างจาก ItemTable ซึ่งออบเจ็คตัวนี้จะทำหน้าที่
#สั่ง ItemSet ประมวลผลเพียงอย่างเดียว โดยมีลูก Child node เป็น ItemSet
#กี่ตัวก็ได้

#วิธีใช้: instance scene : ItemSet ในนี้ได้เลย
#กำหนดค่า parameter ตามต้องการ

#ที่เก็บ ItemSet.tscn:
#res://Misc/InventoryCore/ItemTable/ItemSet/ItemSet.tscn

#หลักการประมวลผล
#อ่าน child node จากออบเจ็คตัวนี้ที่เป็น ItemSet ทั้งหมด ว่าแต่ละตัว
#มีไอเท็มอะไรบ้างและน้ำหนักเท่าไร คืนค่าเป็น Dictionary

tool
extends Node

class_name ItemTable

export (bool) var enabled = true

func get_items() -> Array:
	#ถ้า ItemTable ไม่ได้เปิดใช้งาน ส่ง Array เปล่าไป
	if not enabled:
		return []
	
	var arr := []
	
	for i in get_children():
		if i is ItemSet:
			arr.push_back(i.get_an_item())
	
	return arr