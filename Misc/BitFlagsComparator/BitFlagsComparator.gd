#Bit Flags Comparator
#Code by: Zylann, First
#Ref: Zylann (https://godotengine.org/qa/22370/bit-flags-in-gdscript)

#This is a bit flag system that reduces the need of many if-else statements
#on a bitflag.

#Example:
#
# BitFlags     Value
# 0001       = 1
# 00000101   = 5
# 11111111   = 255
# 01         = 0
# 110        = 6

extends Node
class_name BitFlagsComparator

func is_bit_enabled(var mask : int, var index : int) -> bool:
    return mask & (1 << index) != 0

func enable_bit(var mask : int, var index : int) -> int:
    return mask | (1 << index)

func disable_bit(var mask : int, var index : int) -> int:
    return mask & ~(1 << index)