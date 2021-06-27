# Bit Flags Comparator
#
# This is a bit flag system that reduces the need of many if-else statements
# on a bitflag.
#
# Example:
#  BitFlags     Value
#  0001       = 1
#  00000101   = 5
#  11111111   = 255
#  01         = 0
#  110        = 6

extends Node


static func is_bit_enabled(mask : int, index : int) -> bool:
	return mask & (1 << index) != 0


static func enable_bit(mask : int, index : int) -> int:
	return mask | (1 << index)


static func disable_bit(mask : int, index : int) -> int:
	return mask & ~(1 << index)
