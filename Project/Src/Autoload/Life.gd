# Life
#
# Extra life (1-UP) refers to 'remaining number of tries'.
# It holds the number of remaining lives the player has.

extends Node


const MIN_LIVES = 0

const MAX_LIVES = 9

const DEFAULT_STARTING_LIVES = 2


export (int) var remaining = DEFAULT_STARTING_LIVES setget set_remaining, get_remaining
func set_remaining(val : int) -> void:
	remaining = val
func get_remaining() -> int:
	return remaining


export var starting_lives : int = DEFAULT_STARTING_LIVES



# Reduce number of lives by one. Returns number of lives remaining
# after reduction.
func lose_one_life() -> int:
	remaining -= 1
	return remaining


# Add an extra life. Returns true if remaining lives increase.
# Returns false if remaining lives stuck.
func add_extra_life() -> bool:
	if remaining >= MAX_LIVES:
		return false
	
	remaining += 1
	return true


# Reset remaining lives to default
func reset():
	remaining = starting_lives


# Returns true if the next death would cause a game over.
func is_nearly_game_over():
	return remaining == MIN_LIVES


# Returns true if the remaining lives are all lost.
func is_game_over():
	return remaining < MIN_LIVES


# Get lives digits as text.
# Appends a 0 at the first of the text if the number is a single digit.
func get_lives_digits_text(var live : int = get_remaining()) -> String:
	if live < 10:
		return str(0, live)
	
	return str(live)


# Makes sure the remaining life won't go below default number.
# If it is, fill up to starting_lives value.
# Only useful if you don't want the player to suicide in a level to reset
# remaining lives back to default.
func ensure_starting_lives():
	if remaining < starting_lives:
		remaining = starting_lives
