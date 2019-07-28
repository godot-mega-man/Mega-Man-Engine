#CurvePlus
#Code by: First

#CurvePlus provides more control over to get an even more
#accurated value. 

tool
extends Curve
class_name CurvePlus

export (float) var debug_min_value = 0
export (float) var debug_max_value = 100
export (float) var print_size = 100
export (bool) var print_test setget set_print_test

func set_print_test(var val : bool):
	if val == true:
		for i in print_size + 1:
			print("At ",
				i,
				": value is ",
				debug_min_value + (interpolate(i * (1.0 / print_size)) * (debug_max_value - debug_min_value)),
				"."
			)