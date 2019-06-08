#Rect Helper
#Code by: First

#Rectangle helper follows mouse pointer while in editor. 
#to help visualize the actual position of current mouse pointer.
#You can set extent size to see the shape's size and optionally
#telling position's offset to be either centered or not.

tool
extends ReferenceRect

export var extent : Vector2 = Vector2(24, 24)
export var centered : bool = true

var centered_position : Vector2

func _ready() -> void:
	if !Engine.is_editor_hint():
		push_warning(str(self.get_path(), " is still exist. Please remove before releasing game."))

func _process(delta: float) -> void:
	#Set size by extent
	self.rect_size = extent
	centered_position.x = int(self.rect_size.x / 2)
	centered_position.y = int(self.rect_size.y / 2)
	self.rect_position.x = int(get_global_mouse_position().x) - centered_position.x
	self.rect_position.y = int(get_global_mouse_position().y) - centered_position.y
	
	
	$HelperText.set_text(str(rect_position + (centered_position if centered else Vector2(0, 0))))