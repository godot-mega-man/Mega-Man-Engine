extends TouchScreenButton

export (int, "None", "Top", "Bottom", "Left", "Right") var align_target = 0

onready var active_viewport_rect = get_viewport().get_visible_rect()
onready var origin_global_position = self.global_position

#SIMULATING KEY PRESS FOR WINDOWS
var texture_normal : Texture = self.normal
var texture_pressed : Texture = self.pressed
#END OF SIMULATING KEY PRESS FOR WINDOWS

func _ready():
	align()

func _process(delta: float) -> void:
	#Simulating key press for windows only
	if Input.is_action_pressed(self.action):
		self.normal = texture_pressed
	else:
		self.normal = texture_normal
	pass

func align():
	if align_target == 1:
		push_warning('Not yet supported!')
	if align_target == 2:
		push_warning('Not yet supported!')
	if align_target == 3:
		push_warning('Not yet supported!')
	if align_target == 4:
		self.global_position.x = origin_global_position.x + (active_viewport_rect.size.x - 384)